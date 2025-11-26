<script>
	import { user } from '$lib/stores/auth';
	import { goto } from '$app/navigation';
	import { addLocalCollection, addLocalWords } from '$lib/localDB';

	/** @type {{data: any}} */
	let { data } = $props();

	let showQuickCreate = $state(false);
	let collectionName = $state('');
	let wordPairs = $state([
		{ dutch: '', translation: '' },
		{ dutch: '', translation: '' },
		{ dutch: '', translation: '' }
	]);
	let isCreating = $state(false);
	let errorMessage = $state('');

	function openQuickCreate() {
		showQuickCreate = true;
		collectionName = '';
		wordPairs = [
			{ dutch: '', translation: '' },
			{ dutch: '', translation: '' },
			{ dutch: '', translation: '' }
		];
		errorMessage = '';
	}

	function closeQuickCreate() {
		showQuickCreate = false;
	}

	function addWordPair() {
		wordPairs = [...wordPairs, { dutch: '', translation: '' }];
	}

	function removeWordPair(index) {
		wordPairs = wordPairs.filter((_, i) => i !== index);
	}

	async function handleQuickCreate() {
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

		isCreating = true;

		try {
			const collection = await addLocalCollection(collectionName.trim());

			const wordsToAdd = validWords.map(pair => ({
				dutch: pair.dutch.trim(),
				translation: pair.translation.trim()
			}));

			await addLocalWords(collection.id, wordsToAdd);

			closeQuickCreate();
			goto('/collections');
		} catch (error) {
			errorMessage = error.message || 'Failed to create collection';
		} finally {
			isCreating = false;
		}
	}
</script>

<svelte:head>
	<title>VocabMaster - Master Any Language Through Smart Vocabulary Practice</title>
	<meta name="description" content="Transform your language learning journey with VocabMaster. Create custom word collections, take interactive quizzes, and track your progress as you master new vocabulary." />
</svelte:head>

<section class="hero">
	<div class="hero-content">
		<h1 class="hero-title">Master New Languages,<br>One Word at a Time</h1>

		<p class="hero-description">
			VocabMaster is your personal language learning companion. Build custom vocabulary collections,
			practice with intelligent quizzes, and watch your confidence soar as you become fluent faster than ever before.
		</p>

		{#if !$user}
			<div class="cta">
				<p class="cta-text">Join thousands of learners transforming their language skills</p>
				<div class="cta-buttons">
					<a href="/register" class="btn-primary">Get Started Free</a>
					<a href="/login" class="btn-secondary">Sign In</a>
				</div>
				<p class="cta-note">No credit card required. Start learning in under 60 seconds.</p>
			</div>
		{:else}
			<div class="cta">
				<p class="cta-text">Welcome back! Your vocabulary is waiting.</p>
				<div class="cta-buttons">
					<a href="/quiz" class="btn-primary">Start Practicing Now</a>
					<a href="/collections" class="btn-secondary">Manage Collections</a>
				</div>
			</div>
		{/if}
	</div>
</section>

<section class="quick-start">
	<div class="quick-start-content">
		<h2 class="section-title">Try It Now – No Account Needed</h2>
		<p class="quick-start-subtitle">Create your first vocabulary collection and start practicing in seconds</p>

		<button class="btn-quick-start" onclick={openQuickCreate}>
			<span class="btn-icon">✨</span>
			Create Your First Collection
		</button>

		<p class="quick-start-note">Your collection will be saved locally. Sign up later to sync across devices.</p>
	</div>
</section>

{#if showQuickCreate}
	<div class="modal-overlay" onclick={closeQuickCreate} role="button" tabindex="0">
		<div class="modal" onclick={(e) => e.stopPropagation()} role="dialog">
			<div class="modal-header">
				<h2>Create Your Collection</h2>
				<button class="close-btn" onclick={closeQuickCreate}>✕</button>
			</div>

			<form onsubmit={(e) => { e.preventDefault(); handleQuickCreate(); }}>
				<div class="form-group">
					<label for="collection-name">Collection Name</label>
					<input
						id="collection-name"
						type="text"
						bind:value={collectionName}
						placeholder="e.g., Basic Spanish Verbs"
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
								placeholder="Word (e.g., hello)"
							/>
							<input
								type="text"
								bind:value={pair.translation}
								placeholder="Translation (e.g., hola)"
							/>
							{#if wordPairs.length > 1}
								<button type="button" class="btn-remove" onclick={() => removeWordPair(index)}>✕</button>
							{/if}
						</div>
					{/each}
					<button type="button" class="btn-add-word" onclick={addWordPair}>+ Add Another Word</button>
				</div>

				{#if errorMessage}
					<p class="error">{errorMessage}</p>
				{/if}

				<div class="modal-actions">
					<button type="button" class="btn-secondary" onclick={closeQuickCreate}>Cancel</button>
					<button type="submit" class="btn-primary" disabled={isCreating}>
						{isCreating ? 'Creating...' : 'Create & Start Practicing'}
					</button>
				</div>
			</form>
		</div>
	</div>
{/if}

<section class="features">
	<h2 class="section-title">Why Language Learners Love VocabMaster</h2>

	<div class="features-grid">
		<div class="feature">
			<div class="feature-icon">📚</div>
			<h3>Custom Collections</h3>
			<p>Organize words by themes, lessons, or difficulty. Your vocabulary, your way.</p>
		</div>

		<div class="feature">
			<div class="feature-icon">🎯</div>
			<h3>Smart Quizzes</h3>
			<p>Adaptive practice sessions that focus on words you need to learn most.</p>
		</div>

		<div class="feature">
			<div class="feature-icon">📊</div>
			<h3>Track Progress</h3>
			<p>Visual analytics show your improvement and keep you motivated every day.</p>
		</div>

		<div class="feature">
			<div class="feature-icon">⚡</div>
			<h3>Quick Sessions</h3>
			<p>5-minute practice sessions fit perfectly into your busy schedule.</p>
		</div>

		<div class="feature">
			<div class="feature-icon">🔄</div>
			<h3>Bidirectional Learning</h3>
			<p>Practice both directions to achieve complete mastery of every word.</p>
		</div>

		<div class="feature">
			<div class="feature-icon">🌟</div>
			<h3>Instant Feedback</h3>
			<p>Learn from mistakes immediately and see your accuracy improve session by session.</p>
		</div>
	</div>
</section>

<section class="how-it-works">
	<h2 class="section-title">Start Learning in 3 Simple Steps</h2>

	<div class="steps">
		<div class="step">
			<div class="step-number">1</div>
			<h3>Create Your Collection</h3>
			<p>Add word pairs in your native language and the language you're learning. Organize by topic, lesson, or however makes sense to you.</p>
		</div>

		<div class="step">
			<div class="step-number">2</div>
			<h3>Take the Quiz</h3>
			<p>Choose your direction and start practicing. Type answers, get instant feedback, and watch your accuracy climb.</p>
		</div>

		<div class="step">
			<div class="step-number">3</div>
			<h3>Track Your Growth</h3>
			<p>Review your progress dashboard to see which words you've mastered and which need more practice.</p>
		</div>
	</div>
</section>

<section class="testimonial">
	<blockquote>
		<p class="quote-text">
			"What started as a tool I built for my son has become an integral part of his learning journey.
			He went from struggling with Dutch vocabulary to looking forward to practice time. That's the power
			of the right learning tool."
		</p>
		<cite class="quote-author">— Creator of VocabMaster</cite>
	</blockquote>
</section>

<section class="final-cta">
	<h2>Ready to Transform Your Language Learning?</h2>
	<p>Join learners worldwide who are mastering new languages with VocabMaster</p>

	{#if !$user}
		<div class="cta-buttons">
			<a href="/register" class="btn-primary btn-large">Start Learning Now</a>
			<a href="/about" class="btn-text">Learn more about our mission →</a>
		</div>
	{:else}
		<div class="cta-buttons">
			<a href="/quiz" class="btn-primary btn-large">Continue Your Journey</a>
			<a href="/dashboard" class="btn-text">View Your Progress →</a>
		</div>
	{/if}
</section>

<style>
	section {
		width: 100%;
		padding: 4rem 2rem;
	}

	.hero {
		min-height: 60vh;
		display: flex;
		align-items: center;
		justify-content: center;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		text-align: center;
	}

	.hero-content {
		max-width: 800px;
	}

	.hero-title {
		font-size: 3.5rem;
		font-weight: 800;
		line-height: 1.2;
		margin-bottom: 1.5rem;
		text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
	}

	.hero-description {
		font-size: 1.25rem;
		line-height: 1.8;
		margin-bottom: 3rem;
		opacity: 0.95;
	}

	.cta {
		margin-top: 2rem;
	}

	.cta-text {
		font-size: 1.25rem;
		margin-bottom: 1.5rem;
		font-weight: 500;
	}

	.cta-note {
		margin-top: 1rem;
		font-size: 0.9rem;
		opacity: 0.9;
	}

	.cta-buttons {
		display: flex;
		gap: 1rem;
		justify-content: center;
		flex-wrap: wrap;
	}

	.btn-primary {
		background: white;
		color: #667eea;
		border: none;
		padding: 1rem 2.5rem;
		border-radius: 50px;
		font-size: 1.1rem;
		font-weight: 700;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.3s;
		box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
	}

	.btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
	}

	.btn-secondary {
		background: rgba(255, 255, 255, 0.2);
		color: white;
		border: 2px solid white;
		padding: 1rem 2.5rem;
		border-radius: 50px;
		font-size: 1.1rem;
		font-weight: 700;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.3s;
		backdrop-filter: blur(10px);
	}

	.btn-secondary:hover {
		background: rgba(255, 255, 255, 0.3);
		transform: translateY(-2px);
	}

	.btn-large {
		font-size: 1.25rem;
		padding: 1.25rem 3rem;
	}

	.btn-text {
		background: none;
		color: #667eea;
		border: none;
		padding: 1rem 2rem;
		font-size: 1rem;
		font-weight: 600;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-text:hover {
		color: #764ba2;
		transform: translateX(5px);
	}

	.features {
		background: #f9fafb;
		text-align: center;
	}

	.section-title {
		font-size: 2.5rem;
		color: #1f2937;
		margin-bottom: 3rem;
		font-weight: 700;
	}

	.features-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 2.5rem;
		max-width: 1200px;
		margin: 0 auto;
	}

	.feature {
		background: white;
		padding: 2.5rem 2rem;
		border-radius: 16px;
		box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
		transition: all 0.3s;
	}

	.feature:hover {
		transform: translateY(-8px);
		box-shadow: 0 12px 24px rgba(102, 126, 234, 0.15);
	}

	.feature-icon {
		font-size: 3.5rem;
		margin-bottom: 1.5rem;
	}

	.feature h3 {
		font-size: 1.5rem;
		color: #1f2937;
		margin-bottom: 1rem;
		font-weight: 700;
	}

	.feature p {
		color: #6b7280;
		line-height: 1.6;
		font-size: 1.05rem;
	}

	.how-it-works {
		background: white;
		text-align: center;
	}

	.steps {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		gap: 3rem;
		max-width: 1200px;
		margin: 0 auto;
	}

	.step {
		position: relative;
		text-align: center;
	}

	.step-number {
		width: 80px;
		height: 80px;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 2rem;
		font-weight: 800;
		margin: 0 auto 1.5rem;
		box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
	}

	.step h3 {
		font-size: 1.75rem;
		color: #1f2937;
		margin-bottom: 1rem;
		font-weight: 700;
	}

	.step p {
		color: #6b7280;
		line-height: 1.8;
		font-size: 1.1rem;
	}

	.testimonial {
		background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
		padding: 4rem 2rem;
		text-align: center;
	}

	blockquote {
		max-width: 900px;
		margin: 0 auto;
		border: none;
		padding: 0;
	}

	.quote-text {
		font-size: 1.5rem;
		line-height: 1.8;
		color: #78350f;
		font-style: italic;
		margin-bottom: 1.5rem;
		font-weight: 500;
	}

	.quote-author {
		font-size: 1.1rem;
		color: #92400e;
		font-style: normal;
		font-weight: 600;
	}

	.final-cta {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		text-align: center;
		padding: 5rem 2rem;
	}

	.final-cta h2 {
		font-size: 2.5rem;
		margin-bottom: 1rem;
		font-weight: 800;
	}

	.final-cta p {
		font-size: 1.25rem;
		margin-bottom: 2.5rem;
		opacity: 0.95;
	}

	.final-cta .btn-primary {
		background: white;
		color: #667eea;
	}

	.final-cta .btn-text {
		color: white;
	}

	.final-cta .btn-text:hover {
		color: rgba(255, 255, 255, 0.9);
	}

	.quick-start {
		background: white;
		text-align: center;
		padding: 5rem 2rem;
		border-top: 1px solid #e5e7eb;
		border-bottom: 1px solid #e5e7eb;
	}

	.quick-start-content {
		max-width: 700px;
		margin: 0 auto;
	}

	.quick-start-subtitle {
		font-size: 1.1rem;
		color: #6b7280;
		margin-bottom: 2.5rem;
		line-height: 1.6;
	}

	.btn-quick-start {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		border: none;
		padding: 1.25rem 2.5rem;
		border-radius: 50px;
		font-size: 1.15rem;
		font-weight: 700;
		cursor: pointer;
		transition: all 0.3s;
		box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
		display: inline-flex;
		align-items: center;
		gap: 0.75rem;
	}

	.btn-quick-start:hover {
		transform: translateY(-3px);
		box-shadow: 0 12px 32px rgba(102, 126, 234, 0.4);
	}

	.btn-icon {
		font-size: 1.5rem;
	}

	.quick-start-note {
		margin-top: 1.5rem;
		font-size: 0.95rem;
		color: #9ca3af;
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
		backdrop-filter: blur(4px);
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

	.modal-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 2rem;
	}

	.modal-header h2 {
		margin: 0;
		color: #1f2937;
		font-size: 1.75rem;
		font-weight: 700;
	}

	.close-btn {
		background: none;
		border: none;
		font-size: 1.5rem;
		color: #6b7280;
		cursor: pointer;
		padding: 0.25rem 0.5rem;
		transition: color 0.2s;
	}

	.close-btn:hover {
		color: #1f2937;
	}

	.form-group {
		margin-bottom: 1.5rem;
	}

	.form-group label {
		display: block;
		margin-bottom: 0.5rem;
		color: #374151;
		font-weight: 600;
		font-size: 0.95rem;
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
		gap: 0.75rem;
		margin-bottom: 0.75rem;
		align-items: center;
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
		padding: 0.5rem;
		border-radius: 6px;
		cursor: pointer;
		font-size: 1rem;
		width: 40px;
		height: 40px;
		transition: all 0.2s;
	}

	.btn-remove:hover {
		background: #dc2626;
	}

	.btn-add-word {
		background: #f3f4f6;
		color: #667eea;
		border: 2px dashed #d1d5db;
		padding: 0.75rem 1.5rem;
		border-radius: 8px;
		cursor: pointer;
		font-size: 0.95rem;
		font-weight: 600;
		width: 100%;
		transition: all 0.2s;
		margin-top: 0.5rem;
	}

	.btn-add-word:hover {
		background: #e5e7eb;
		border-color: #667eea;
	}

	.modal-actions {
		display: flex;
		gap: 1rem;
		justify-content: flex-end;
		margin-top: 2rem;
	}

	.modal-actions .btn-primary {
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

	.modal-actions .btn-primary:hover:not(:disabled) {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
	}

	.modal-actions .btn-primary:disabled {
		opacity: 0.6;
		cursor: not-allowed;
		transform: none;
	}

	.modal-actions .btn-secondary {
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

	.modal-actions .btn-secondary:hover {
		background: #e5e7eb;
		border-color: #d1d5db;
	}

	.error {
		color: #ef4444;
		font-size: 0.875rem;
		margin-top: 0.5rem;
	}

	@media (max-width: 768px) {
		.hero-title {
			font-size: 2.5rem;
		}

		.hero-description {
			font-size: 1.1rem;
		}

		.section-title {
			font-size: 2rem;
		}

		.features-grid,
		.steps {
			grid-template-columns: 1fr;
		}

		.quote-text {
			font-size: 1.25rem;
		}

		.btn-primary,
		.btn-secondary {
			padding: 0.875rem 2rem;
			font-size: 1rem;
		}

		section {
			padding: 3rem 1.5rem;
		}

		.word-pair {
			grid-template-columns: 1fr;
		}

		.btn-remove {
			width: 100%;
		}

		.modal {
			padding: 1.5rem;
		}

		.modal-actions {
			flex-direction: column;
		}

		.modal-actions button {
			width: 100%;
		}
	}
</style>
