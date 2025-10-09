<script>
	import { supabase } from '$lib/supabase';
	import { invalidateAll } from '$app/navigation';

	/** @type {{data: any}} */
	let { data } = $props();

	let showModal = $state(false);
	let showAddWordsModal = $state(false);
	let showDeleteConfirm = $state(false);
	let collectionName = $state('');
	let wordPairs = $state([{ dutch: '', translation: '' }]);
	let isSubmitting = $state(false);
	let errorMessage = $state('');
	let selectedCollectionForWords = $state(null);
	let newWords = $state([{ dutch: '', translation: '' }]);
	let collectionToDelete = $state(null);

	function openModal() {
		showModal = true;
		collectionName = '';
		wordPairs = [{ dutch: '', translation: '' }];
		errorMessage = '';
	}

	function closeModal() {
		showModal = false;
	}

	function openAddWordsModal(collection) {
		selectedCollectionForWords = collection;
		newWords = [{ dutch: '', translation: '' }];
		showAddWordsModal = true;
		errorMessage = '';
	}

	function closeAddWordsModal() {
		showAddWordsModal = false;
		selectedCollectionForWords = null;
	}

	function addWordPair() {
		wordPairs = [...wordPairs, { dutch: '', translation: '' }];
	}

	function removeWordPair(index) {
		wordPairs = wordPairs.filter((_, i) => i !== index);
	}

	function addNewWordPair() {
		newWords = [...newWords, { dutch: '', translation: '' }];
	}

	function removeNewWordPair(index) {
		newWords = newWords.filter((_, i) => i !== index);
	}

	async function handleSubmit() {
		errorMessage = '';

		if (!collectionName.trim()) {
			errorMessage = 'Please enter a collection name';
			return;
		}

		const validWords = wordPairs.filter(pair => pair.dutch.trim() && pair.translation.trim());

		if (validWords.length === 0) {
			errorMessage = 'Please add at least one word pair';
			return;
		}

		isSubmitting = true;

		try {
			const { data: collection, error: collectionError } = await supabase
				.from('collections')
				.insert([{ name: collectionName.trim() }])
				.select()
				.single();

			if (collectionError) throw collectionError;

			const wordsToInsert = validWords.map(pair => ({
				collection_id: collection.id,
				dutch: pair.dutch.trim(),
				translation: pair.translation.trim()
			}));

			const { error: wordsError } = await supabase
				.from('words')
				.insert(wordsToInsert);

			if (wordsError) throw wordsError;

			await invalidateAll();
			closeModal();
		} catch (error) {
			errorMessage = error.message || 'Failed to create collection';
		} finally {
			isSubmitting = false;
		}
	}

	async function handleAddWords() {
		errorMessage = '';

		if (!selectedCollectionForWords) {
			errorMessage = 'No collection selected';
			return;
		}

		const validWords = newWords.filter(pair => pair.dutch.trim() && pair.translation.trim());

		if (validWords.length === 0) {
			errorMessage = 'Please add at least one word pair';
			return;
		}

		isSubmitting = true;

		try {
			const wordsToInsert = validWords.map(pair => ({
				collection_id: selectedCollectionForWords.id,
				dutch: pair.dutch.trim(),
				translation: pair.translation.trim()
			}));

			const { error: wordsError } = await supabase
				.from('words')
				.insert(wordsToInsert);

			if (wordsError) throw wordsError;

			await invalidateAll();
			closeAddWordsModal();
		} catch (error) {
			errorMessage = error.message || 'Failed to add words';
		} finally {
			isSubmitting = false;
		}
	}

	function openDeleteConfirm(collection) {
		collectionToDelete = collection;
		showDeleteConfirm = true;
	}

	function closeDeleteConfirm() {
		showDeleteConfirm = false;
		collectionToDelete = null;
	}

	async function handleDelete() {
		if (!collectionToDelete) return;

		isSubmitting = true;
		errorMessage = '';

		try {
			const { error } = await supabase
				.from('collections')
				.delete()
				.eq('id', collectionToDelete.id);

			if (error) throw error;

			await invalidateAll();
			closeDeleteConfirm();
		} catch (error) {
			errorMessage = error.message || 'Failed to delete collection';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>Collections</title>
	<meta name="description" content="Added collections" />
</svelte:head>

<div class="container">
	<div class="header">
		<h1>Collections</h1>
		<button class="btn-primary" onclick={openModal}>Add Collection</button>
	</div>

	{#if data?.collections && data.collections.length > 0}
		<div class="collections-grid">
			{#each data.collections as collection}
				<div class="collection-card">
					<div class="card-header">
						<h2>{collection.name}</h2>
						<div class="card-actions">
							<button class="btn-add-words" onclick={() => openAddWordsModal(collection)} title="Add words">
								+ Add Words
							</button>
							<button class="btn-delete" onclick={() => openDeleteConfirm(collection)} title="Delete collection">
								Delete
							</button>
						</div>
					</div>
					{#if collection.words && collection.words.length > 0}
						<p class="word-count">{collection.words.length} word{collection.words.length !== 1 ? 's' : ''}</p>
						<ul>
							{#each collection.words as word}
								<li>
									<strong>{word.dutch}</strong> - {word.translation}
								</li>
							{/each}
						</ul>
					{:else}
						<p class="empty">No words yet</p>
					{/if}
				</div>
			{/each}
		</div>
	{:else}
		<p class="empty">No collections found</p>
	{/if}
</div>

{#if showModal}
	<div class="modal-overlay" onclick={closeModal}>
		<div class="modal" onclick={(e) => e.stopPropagation()}>
			<div class="modal-header">
				<h2>Add New Collection</h2>
				<button class="btn-close" onclick={closeModal}>&times;</button>
			</div>

			<form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
				<div class="form-group">
					<label for="collection-name">Collection Name</label>
					<input
						id="collection-name"
						type="text"
						bind:value={collectionName}
						placeholder="e.g., French, Spanish"
						required
					/>
				</div>

				<div class="form-group">
					<label>Word Pairs</label>
					{#each wordPairs as pair, index}
						<div class="word-pair">
							<input
								type="text"
								bind:value={pair.dutch}
								placeholder="Dutch word"
								required
							/>
							<input
								type="text"
								bind:value={pair.translation}
								placeholder="Translation"
								required
							/>
							{#if wordPairs.length > 1}
								<button
									type="button"
									class="btn-remove"
									onclick={() => removeWordPair(index)}
								>
									Remove
								</button>
							{/if}
						</div>
					{/each}
					<button type="button" class="btn-secondary" onclick={addWordPair}>
						Add Word Pair
					</button>
				</div>

				{#if errorMessage}
					<p class="error">{errorMessage}</p>
				{/if}

				<div class="modal-actions">
					<button type="button" class="btn-secondary" onclick={closeModal} disabled={isSubmitting}>
						Cancel
					</button>
					<button type="submit" class="btn-primary" disabled={isSubmitting}>
						{isSubmitting ? 'Creating...' : 'Create Collection'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

{#if showAddWordsModal}
	<div class="modal-overlay" onclick={closeAddWordsModal}>
		<div class="modal" onclick={(e) => e.stopPropagation()}>
			<div class="modal-header">
				<h2>Add Words to {selectedCollectionForWords?.name}</h2>
				<button class="btn-close" onclick={closeAddWordsModal}>&times;</button>
			</div>

			<form onsubmit={(e) => { e.preventDefault(); handleAddWords(); }}>
				<div class="form-group">
					<label>Word Pairs</label>
					{#each newWords as pair, index}
						<div class="word-pair">
							<input
								type="text"
								bind:value={pair.dutch}
								placeholder="Dutch word"
								required
							/>
							<input
								type="text"
								bind:value={pair.translation}
								placeholder="Translation"
								required
							/>
							{#if newWords.length > 1}
								<button
									type="button"
									class="btn-remove"
									onclick={() => removeNewWordPair(index)}
								>
									Remove
								</button>
							{/if}
						</div>
					{/each}
					<button type="button" class="btn-secondary" onclick={addNewWordPair}>
						Add Word Pair
					</button>
				</div>

				{#if errorMessage}
					<p class="error">{errorMessage}</p>
				{/if}

				<div class="modal-actions">
					<button type="button" class="btn-secondary" onclick={closeAddWordsModal} disabled={isSubmitting}>
						Cancel
					</button>
					<button type="submit" class="btn-primary" disabled={isSubmitting}>
						{isSubmitting ? 'Adding...' : 'Add Words'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

{#if showDeleteConfirm}
	<div class="modal-overlay" onclick={closeDeleteConfirm}>
		<div class="modal modal-small" onclick={(e) => e.stopPropagation()}>
			<div class="modal-header">
				<h2>Delete Collection?</h2>
				<button class="btn-close" onclick={closeDeleteConfirm}>&times;</button>
			</div>

			<div class="modal-content">
				<p>Are you sure you want to delete <strong>{collectionToDelete?.name}</strong>?</p>
				<p class="warning-text">This will permanently delete the collection and all its words. This action cannot be undone.</p>

				{#if errorMessage}
					<p class="error">{errorMessage}</p>
				{/if}
			</div>

			<div class="modal-actions">
				<button class="btn-secondary" onclick={closeDeleteConfirm} disabled={isSubmitting}>
					Cancel
				</button>
				<button class="btn-danger" onclick={handleDelete} disabled={isSubmitting}>
					{isSubmitting ? 'Deleting...' : 'Delete Collection'}
				</button>
			</div>
		</div>
	</div>
{/if}

<style>
	.container {
		max-width: 1200px;
	}

	.header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 2rem;
	}

	h1 {
		margin: 0;
		color: #333;
	}

	.btn-primary {
		background: #2563eb;
		color: white;
		border: none;
		padding: 0.75rem 1.5rem;
		border-radius: 6px;
		font-size: 1rem;
		cursor: pointer;
		transition: background 0.2s;
	}

	.btn-primary:hover:not(:disabled) {
		background: #1d4ed8;
	}

	.btn-primary:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.btn-secondary {
		background: #f3f4f6;
		color: #374151;
		border: 1px solid #d1d5db;
		padding: 0.75rem 1.5rem;
		border-radius: 6px;
		font-size: 1rem;
		cursor: pointer;
		transition: background 0.2s;
	}

	.btn-secondary:hover:not(:disabled) {
		background: #e5e7eb;
	}

	.btn-secondary:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.collections-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
		gap: 1.5rem;
	}

	.collection-card {
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 8px;
		padding: 1.5rem;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
		transition: box-shadow 0.2s;
	}

	.collection-card:hover {
		box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
	}

	.card-header {
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
		margin-bottom: 0.5rem;
		gap: 1rem;
	}

	h2 {
		margin: 0;
		color: #333;
		font-size: 1.5rem;
		flex: 1;
	}

	.card-actions {
		display: flex;
		gap: 0.5rem;
		flex-shrink: 0;
	}

	.btn-add-words {
		background: #10b981;
		color: white;
		border: none;
		padding: 0.5rem 0.75rem;
		border-radius: 4px;
		font-size: 0.875rem;
		cursor: pointer;
		transition: background 0.2s;
		white-space: nowrap;
	}

	.btn-add-words:hover {
		background: #059669;
	}

	.btn-delete {
		background: #ef4444;
		color: white;
		border: none;
		padding: 0.5rem 0.75rem;
		border-radius: 4px;
		font-size: 0.875rem;
		cursor: pointer;
		transition: background 0.2s;
		white-space: nowrap;
	}

	.btn-delete:hover {
		background: #dc2626;
	}

	.btn-danger {
		background: #ef4444;
		color: white;
		border: none;
		padding: 0.75rem 1.5rem;
		border-radius: 6px;
		font-size: 1rem;
		cursor: pointer;
		transition: background 0.2s;
	}

	.btn-danger:hover:not(:disabled) {
		background: #dc2626;
	}

	.btn-danger:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.word-count {
		color: #666;
		font-size: 0.9rem;
		margin-bottom: 1rem;
	}

	ul {
		list-style: none;
		padding: 0;
		margin: 0;
	}

	li {
		padding: 0.5rem;
		margin: 0.5rem 0;
		background: #f5f5f5;
		border-radius: 4px;
		font-size: 0.9rem;
	}

	.empty {
		color: #999;
		font-style: italic;
	}

	.modal-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: rgba(0, 0, 0, 0.5);
		display: flex;
		justify-content: center;
		align-items: center;
		z-index: 1000;
	}

	.modal {
		background: white;
		border-radius: 12px;
		padding: 2rem;
		max-width: 600px;
		width: 90%;
		max-height: 90vh;
		overflow-y: auto;
		box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
	}

	.modal-small {
		max-width: 500px;
	}

	.modal-content {
		margin-bottom: 1.5rem;
	}

	.modal-content p {
		margin: 0.5rem 0;
		color: #374151;
	}

	.warning-text {
		color: #dc2626;
		font-size: 0.95rem;
		font-weight: 500;
		margin-top: 1rem;
	}

	.modal-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 1.5rem;
	}

	.modal-header h2 {
		margin: 0;
		font-size: 1.5rem;
	}

	.btn-close {
		background: none;
		border: none;
		font-size: 2rem;
		color: #6b7280;
		cursor: pointer;
		padding: 0;
		width: 2rem;
		height: 2rem;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: color 0.2s;
	}

	.btn-close:hover {
		color: #374151;
	}

	.form-group {
		margin-bottom: 1.5rem;
	}

	.form-group label {
		display: block;
		margin-bottom: 0.5rem;
		color: #374151;
		font-weight: 500;
	}

	.form-group input {
		width: 100%;
		padding: 0.75rem;
		border: 1px solid #d1d5db;
		border-radius: 6px;
		font-size: 1rem;
		box-sizing: border-box;
	}

	.form-group input:focus {
		outline: none;
		border-color: #2563eb;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
	}

	.word-pair {
		display: grid;
		grid-template-columns: 1fr 1fr auto;
		gap: 0.5rem;
		margin-bottom: 0.75rem;
		align-items: center;
	}

	.word-pair input {
		padding: 0.75rem;
		border: 1px solid #d1d5db;
		border-radius: 6px;
		font-size: 0.9rem;
	}

	.word-pair input:focus {
		outline: none;
		border-color: #2563eb;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
	}

	.btn-remove {
		background: #ef4444;
		color: white;
		border: none;
		padding: 0.5rem 0.75rem;
		border-radius: 6px;
		font-size: 0.875rem;
		cursor: pointer;
		white-space: nowrap;
		transition: background 0.2s;
	}

	.btn-remove:hover {
		background: #dc2626;
	}

	.modal-actions {
		display: flex;
		justify-content: flex-end;
		gap: 1rem;
		margin-top: 2rem;
	}

	.error {
		color: #ef4444;
		font-size: 0.875rem;
		margin-top: 0.5rem;
	}
</style>