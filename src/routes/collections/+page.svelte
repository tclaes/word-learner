<script>
	import { supabase } from '$lib/supabase';
	import { user } from '$lib/stores/auth';
	import { invalidateAll } from '$app/navigation';
	import { onMount } from 'svelte';
	import {
		getLocalCollections,
		addLocalCollection,
		updateLocalCollection,
		deleteLocalCollection,
		addLocalWords,
		deleteLocalWords
	} from '$lib/localDB';

	/** @type {{data: any}} */
	let { data } = $props();

	let collections = $state(data.collections || []);
	let isAuthenticated = $state(data.isAuthenticated);

	let showModal = $state(false);
	let showAddWordsModal = $state(false);
	let showDeleteConfirm = $state(false);
	let showEditModal = $state(false);
	let collectionName = $state('');
	let wordPairs = $state([{ dutch: '', translation: '' }]);
	let isSubmitting = $state(false);
	let errorMessage = $state('');
	let selectedCollectionForWords = $state(null);
	let newWords = $state([{ dutch: '', translation: '' }]);
	let collectionToDelete = $state(null);
	let collectionToEdit = $state(null);
	let editWords = $state([]);

	onMount(async () => {
		if (!isAuthenticated) {
			await loadLocalCollections();
		}
	});

	async function loadLocalCollections() {
		try {
			collections = await getLocalCollections();
		} catch (error) {
			console.error('Error loading local collections:', error);
			collections = [];
		}
	}

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
			if (isAuthenticated) {
				const { data: { user } } = await supabase.auth.getUser();

				if (!user) {
					errorMessage = 'You must be logged in to create collections';
					return;
				}

				const { data: collection, error: collectionError } = await supabase
					.from('collections')
					.insert([{ name: collectionName.trim(), user_id: user.id }])
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
			} else {
				const collection = await addLocalCollection(collectionName.trim());

				const wordsToAdd = validWords.map(pair => ({
					dutch: pair.dutch.trim(),
					translation: pair.translation.trim()
				}));

				await addLocalWords(collection.id, wordsToAdd);
				await loadLocalCollections();
			}

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
			if (isAuthenticated) {
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
			} else {
				const wordsToAdd = validWords.map(pair => ({
					dutch: pair.dutch.trim(),
					translation: pair.translation.trim()
				}));

				await addLocalWords(selectedCollectionForWords.id, wordsToAdd);
				await loadLocalCollections();
			}

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
			if (isAuthenticated) {
				const { error } = await supabase
					.from('collections')
					.delete()
					.eq('id', collectionToDelete.id);

				if (error) throw error;

				await invalidateAll();
			} else {
				await deleteLocalCollection(collectionToDelete.id);
				await loadLocalCollections();
			}

			closeDeleteConfirm();
		} catch (error) {
			errorMessage = error.message || 'Failed to delete collection';
		} finally {
			isSubmitting = false;
		}
	}

	function openEditModal(collection) {
		collectionToEdit = collection;
		collectionName = collection.name;
		editWords = collection.words?.map(word => ({ ...word })) || [];
		showEditModal = true;
		errorMessage = '';
	}

	function closeEditModal() {
		showEditModal = false;
		collectionToEdit = null;
		collectionName = '';
		editWords = [];
	}

	function addEditWordPair() {
		editWords = [...editWords, { dutch: '', translation: '' }];
	}

	function removeEditWordPair(index) {
		editWords = editWords.filter((_, i) => i !== index);
	}

	async function handleEdit() {
		if (!collectionToEdit) return;

		errorMessage = '';

		if (!collectionName.trim()) {
			errorMessage = 'Please enter a collection name';
			return;
		}

		const validWords = editWords.filter(word => word.dutch?.trim() && word.translation?.trim());

		if (validWords.length === 0) {
			errorMessage = 'Please add at least one word pair';
			return;
		}

		isSubmitting = true;

		try {
			if (isAuthenticated) {
				const { error: updateError } = await supabase
					.from('collections')
					.update({ name: collectionName.trim() })
					.eq('id', collectionToEdit.id);

				if (updateError) throw updateError;

				const { error: deleteError } = await supabase
					.from('words')
					.delete()
					.eq('collection_id', collectionToEdit.id);

				if (deleteError) throw deleteError;

				const wordsToInsert = validWords.map(word => ({
					collection_id: collectionToEdit.id,
					dutch: word.dutch.trim(),
					translation: word.translation.trim()
				}));

				const { error: insertError } = await supabase
					.from('words')
					.insert(wordsToInsert);

				if (insertError) throw insertError;

				await invalidateAll();
			} else {
				await updateLocalCollection(collectionToEdit.id, collectionName.trim());
				await deleteLocalWords(collectionToEdit.id);

				const wordsToAdd = validWords.map(word => ({
					dutch: word.dutch.trim(),
					translation: word.translation.trim()
				}));

				await addLocalWords(collectionToEdit.id, wordsToAdd);
				await loadLocalCollections();
			}

			closeEditModal();
		} catch (error) {
			errorMessage = error.message || 'Failed to update collection';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>My Collections - VocabMaster</title>
	<meta name="description" content="Manage your vocabulary collections" />
</svelte:head>

<div class="container">
	{#if !isAuthenticated && collections.length > 0}
		<div class="guest-banner">
			<div class="banner-content">
				<div class="banner-icon">💾</div>
				<div class="banner-text">
					<h3>Save Your Progress</h3>
					<p>Create an account to sync your collections across devices and never lose your progress!</p>
				</div>
				<div class="banner-actions">
					<a href="/register" class="btn-banner">Sign Up Free</a>
				</div>
			</div>
		</div>
	{/if}

	<div class="header">
		<h1>Collections</h1>
		<button class="btn-primary" onclick={openModal}>Add Collection</button>
	</div>

	{#if collections && collections.length > 0}
		<div class="collections-grid">
			{#each collections as collection}
				<div class="collection-card">
					<div class="card-header">
						<h2>{collection.name}</h2>
						<div class="card-actions">
							<button class="btn-edit" onclick={() => openEditModal(collection)} title="Edit collection">
								Edit
							</button>
							<button class="btn-add-words" onclick={() => openAddWordsModal(collection)} title="Add words">
								+ Add Words
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
					<button class="btn-delete" onclick={() => openDeleteConfirm(collection)} title="Delete collection">
						Delete
					</button>
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

{#if showEditModal}
	<div class="modal-overlay" onclick={closeEditModal}>
		<div class="modal" onclick={(e) => e.stopPropagation()}>
			<div class="modal-header">
				<h2>Edit Collection</h2>
				<button class="btn-close" onclick={closeEditModal}>&times;</button>
			</div>

			<form onsubmit={(e) => { e.preventDefault(); handleEdit(); }}>
				<div class="form-group">
					<label for="edit-collection-name">Collection Name</label>
					<input
						id="edit-collection-name"
						type="text"
						bind:value={collectionName}
						placeholder="Enter collection name"
						required
					/>
				</div>

				<div class="form-group">
					<label>Word Pairs</label>
					{#each editWords as word, index}
						<div class="word-pair">
							<input
								type="text"
								bind:value={word.dutch}
								placeholder="Dutch word"
								required
							/>
							<input
								type="text"
								bind:value={word.translation}
								placeholder="Translation"
								required
							/>
							{#if editWords.length > 1}
								<button
									type="button"
									class="btn-remove"
									onclick={() => removeEditWordPair(index)}
								>
									Remove
								</button>
							{/if}
						</div>
					{/each}
					<button type="button" class="btn-secondary" onclick={addEditWordPair}>
						Add Word Pair
					</button>
				</div>

				{#if errorMessage}
					<p class="error">{errorMessage}</p>
				{/if}

				<div class="modal-actions">
					<button type="button" class="btn-secondary" onclick={closeEditModal} disabled={isSubmitting}>
						Cancel
					</button>
					<button type="submit" class="btn-primary" disabled={isSubmitting}>
						{isSubmitting ? 'Updating...' : 'Update Collection'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<style>
	.container {
		padding: 3rem 2rem;
		max-width: 1200px;
		margin: 0 auto;
		min-height: calc(100vh - 200px);
	}

	.header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 3rem;
		gap: 1rem;
		flex-wrap: wrap;
	}

	h1 {
		margin: 0;
		color: #1f2937;
		font-size: 2.5rem;
		font-weight: 800;
	}

	.btn-primary {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		border: none;
		padding: 0.875rem 1.75rem;
		border-radius: 8px;
		font-size: 1rem;
		font-weight: 700;
		cursor: pointer;
		transition: all 0.3s;
		box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
	}

	.btn-primary:hover:not(:disabled) {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
	}

	.btn-primary:disabled {
		opacity: 0.6;
		cursor: not-allowed;
		transform: none;
	}

	.btn-secondary {
		background: #f3f4f6;
		color: #374151;
		border: 2px solid #e5e7eb;
		padding: 0.75rem 1.5rem;
		border-radius: 8px;
		font-size: 1rem;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-secondary:hover:not(:disabled) {
		background: #e5e7eb;
		border-color: #d1d5db;
	}

	.btn-secondary:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.collections-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
		gap: 2rem;
	}

	.collection-card {
		background: white;
		border: 2px solid #e5e7eb;
		border-radius: 16px;
		padding: 2rem;
		box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
		transition: all 0.3s;
	}

	.collection-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 12px 24px rgba(102, 126, 234, 0.15);
		border-color: #667eea;
	}

	.card-header {
		display: flex;
		justify-content: space-between;
		align-items: flex-start;
		margin-bottom: 0.5rem;
		gap: 1rem;
		flex-wrap: wrap;
	}

	h2 {
		margin: 0;
		color: #1f2937;
		font-size: 1.5rem;
		font-weight: 700;
		flex: 1;
		min-width: 0;
		word-wrap: break-word;
	}

	.card-actions {
		display: flex;
		gap: 0.5rem;
		flex-shrink: 0;
		flex-wrap: wrap;
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

	.btn-edit {
		background: #3b82f6;
		color: white;
		border: none;
		padding: 0.5rem 0.75rem;
		border-radius: 4px;
		font-size: 0.875rem;
		cursor: pointer;
		transition: background 0.2s;
		white-space: nowrap;
	}

	.btn-edit:hover {
		background: #2563eb;
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
		width: 100%;
		margin-top: 1rem;
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
		border-radius: 16px;
		padding: 2.5rem;
		max-width: 600px;
		width: 90%;
		max-height: 90vh;
		overflow-y: auto;
		box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
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
		padding: 0.875rem 1rem;
		border: 2px solid #e5e7eb;
		border-radius: 8px;
		font-size: 1rem;
		box-sizing: border-box;
		background: #f9fafb;
		transition: all 0.2s;
	}

	.form-group input:hover {
		border-color: #d1d5db;
	}

	.form-group input:focus {
		outline: none;
		border-color: #667eea;
		box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
		background: white;
	}

	.word-pair {
		display: grid;
		grid-template-columns: 1fr 1fr auto;
		gap: 0.5rem;
		margin-bottom: 0.75rem;
		align-items: center;
	}

	@media (max-width: 768px) {
		.container {
			padding: 1rem;
		}

		.header {
			flex-direction: column;
			align-items: stretch;
		}

		.header .btn-primary {
			width: 100%;
		}

		.collections-grid {
			grid-template-columns: 1fr;
		}

		.card-header {
			flex-direction: column;
			align-items: stretch;
		}

		.card-actions {
			width: 100%;
			justify-content: stretch;
		}

		.btn-edit,
		.btn-add-words {
			flex: 1;
		}

		.word-pair {
			grid-template-columns: 1fr;
			gap: 0.75rem;
		}

		.btn-remove {
			width: 100%;
		}
	}

	.word-pair input {
		padding: 0.875rem 1rem;
		border: 2px solid #e5e7eb;
		border-radius: 8px;
		font-size: 0.9rem;
		background: #f9fafb;
		transition: all 0.2s;
	}

	.word-pair input:hover {
		border-color: #d1d5db;
	}

	.word-pair input:focus {
		outline: none;
		border-color: #667eea;
		box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
		background: white;
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

	.guest-banner {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		border-radius: 16px;
		padding: 2rem;
		margin-bottom: 2rem;
		box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
	}

	.banner-content {
		display: flex;
		align-items: center;
		gap: 1.5rem;
		flex-wrap: wrap;
	}

	.banner-icon {
		font-size: 3rem;
		flex-shrink: 0;
	}

	.banner-text {
		flex: 1;
		min-width: 250px;
	}

	.banner-text h3 {
		margin: 0 0 0.5rem 0;
		color: white;
		font-size: 1.5rem;
		font-weight: 700;
	}

	.banner-text p {
		margin: 0;
		color: rgba(255, 255, 255, 0.95);
		font-size: 1rem;
		line-height: 1.6;
	}

	.banner-actions {
		flex-shrink: 0;
	}

	.btn-banner {
		display: inline-block;
		background: white;
		color: #667eea;
		border: none;
		padding: 0.875rem 1.75rem;
		border-radius: 8px;
		font-size: 1rem;
		font-weight: 700;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.3s;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
	}

	.btn-banner:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
	}

	@media (max-width: 768px) {
		.banner-content {
			flex-direction: column;
			text-align: center;
		}

		.banner-actions {
			width: 100%;
		}

		.btn-banner {
			width: 100%;
		}
	}
</style>