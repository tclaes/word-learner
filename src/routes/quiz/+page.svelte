<script>
	let { data } = $props();

	let selectedCollection = $state(null);
	let quizStarted = $state(false);
	let currentWord = $state(null);
	let userAnswer = $state('');
	let score = $state(0);
	let totalAnswered = $state(0);
	let feedback = $state('');
	let usedWords = $state([]);

	function selectCollection(collection) {
		selectedCollection = collection;
		quizStarted = false;
		resetQuiz();
	}

	function startQuiz() {
		if (!selectedCollection || !selectedCollection.words || selectedCollection.words.length === 0) {
			return;
		}
		quizStarted = true;
		resetQuiz();
		nextWord();
	}

	function resetQuiz() {
		score = 0;
		totalAnswered = 0;
		feedback = '';
		usedWords = [];
		userAnswer = '';
		currentWord = null;
	}

	function nextWord() {
		if (!selectedCollection || !selectedCollection.words) return;

		const availableWords = selectedCollection.words.filter(
			word => !usedWords.includes(word.id)
		);

		if (availableWords.length === 0) {
			usedWords = [];
			const randomIndex = Math.floor(Math.random() * selectedCollection.words.length);
			currentWord = selectedCollection.words[randomIndex];
		} else {
			const randomIndex = Math.floor(Math.random() * availableWords.length);
			currentWord = availableWords[randomIndex];
		}

		userAnswer = '';
		feedback = '';
	}

	function checkAnswer() {
		if (!currentWord || !userAnswer.trim()) return;

		totalAnswered++;

		const correctAnswer = currentWord.translation.toLowerCase().trim();
		const userAnswerNormalized = userAnswer.toLowerCase().trim();

		if (userAnswerNormalized === correctAnswer) {
			score++;
			feedback = 'correct';
		} else {
			feedback = 'incorrect';
		}

		usedWords = [...usedWords, currentWord.id];

		setTimeout(() => {
			nextWord();
		}, 1500);
	}

	function handleKeyPress(event) {
		if (event.key === 'Enter') {
			checkAnswer();
		}
	}
</script>

<svelte:head>
	<title>Quiz</title>
	<meta name="description" content="Test your vocabulary" />
</svelte:head>

<div class="container">
	<h1>Vocabulary Quiz</h1>

	{#if !selectedCollection}
		<div class="collection-selection">
			<h2>Select a Collection</h2>
			{#if data?.collections && data.collections.length > 0}
				<div class="collections-grid">
					{#each data.collections as collection}
						<button class="collection-card" onclick={() => selectCollection(collection)}>
							<h3>{collection.name}</h3>
							<p class="word-count">
								{collection.words?.length || 0} word{collection.words?.length !== 1 ? 's' : ''}
							</p>
						</button>
					{/each}
				</div>
			{:else}
				<p class="empty">No collections available. Create a collection first.</p>
			{/if}
		</div>
	{:else if !quizStarted}
		<div class="quiz-setup">
			<h2>Ready to start?</h2>
			<p class="collection-name">Collection: <strong>{selectedCollection.name}</strong></p>
			<p class="word-count">
				{selectedCollection.words?.length || 0} word{selectedCollection.words?.length !== 1 ? 's' : ''}
			</p>
			<div class="button-group">
				<button class="btn-secondary" onclick={() => (selectedCollection = null)}>
					Choose Different Collection
				</button>
				<button class="btn-primary" onclick={startQuiz}>Start Quiz</button>
			</div>
		</div>
	{:else}
		<div class="quiz-area">
			<div class="score-board">
				<div class="score-item">
					<span class="label">Score:</span>
					<span class="value">{score} / {totalAnswered}</span>
				</div>
				{#if totalAnswered > 0}
					<div class="score-item">
						<span class="label">Accuracy:</span>
						<span class="value">{Math.round((score / totalAnswered) * 100)}%</span>
					</div>
				{/if}
			</div>

			{#if currentWord}
				<div class="quiz-card" class:correct={feedback === 'correct'} class:incorrect={feedback === 'incorrect'}>
					<div class="word-display">
						<p class="label">Translate this word:</p>
						<h2 class="dutch-word">{currentWord.dutch}</h2>
					</div>

					{#if feedback === ''}
						<div class="answer-input">
							<input
								type="text"
								bind:value={userAnswer}
								onkeypress={handleKeyPress}
								placeholder="Type your answer"
								autofocus
							/>
							<button class="btn-primary" onclick={checkAnswer} disabled={!userAnswer.trim()}>
								Check Answer
							</button>
						</div>
					{:else if feedback === 'correct'}
						<div class="feedback correct-feedback">
							<p class="icon">✓</p>
							<p class="message">Correct!</p>
						</div>
					{:else if feedback === 'incorrect'}
						<div class="feedback incorrect-feedback">
							<p class="icon">✗</p>
							<p class="message">Incorrect. The answer was: <strong>{currentWord.translation}</strong></p>
						</div>
					{/if}
				</div>
			{/if}

			<div class="quiz-actions">
				<button class="btn-secondary" onclick={() => { quizStarted = false; resetQuiz(); }}>
					End Quiz
				</button>
			</div>
		</div>
	{/if}
</div>

<style>
	.container {
		padding: 2rem;
		max-width: 900px;
		margin: 0 auto;
	}

	h1 {
		text-align: center;
		color: #333;
		margin-bottom: 2rem;
	}

	.collection-selection {
		text-align: center;
	}

	.collection-selection h2 {
		color: #333;
		margin-bottom: 1.5rem;
	}

	.collections-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
		gap: 1rem;
		margin-top: 1.5rem;
	}

	.collection-card {
		background: #fff;
		border: 2px solid #e0e0e0;
		border-radius: 8px;
		padding: 1.5rem;
		cursor: pointer;
		transition: all 0.2s;
		text-align: center;
	}

	.collection-card:hover {
		border-color: #2563eb;
		box-shadow: 0 4px 12px rgba(37, 99, 235, 0.15);
		transform: translateY(-2px);
	}

	.collection-card h3 {
		margin: 0 0 0.5rem 0;
		color: #333;
		font-size: 1.25rem;
	}

	.word-count {
		color: #666;
		font-size: 0.9rem;
		margin: 0;
	}

	.quiz-setup {
		text-align: center;
		padding: 2rem;
		background: #fff;
		border-radius: 12px;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
	}

	.quiz-setup h2 {
		color: #333;
		margin-bottom: 1rem;
	}

	.collection-name {
		font-size: 1.1rem;
		color: #666;
		margin: 1rem 0;
	}

	.button-group {
		display: flex;
		gap: 1rem;
		justify-content: center;
		margin-top: 2rem;
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

	.btn-secondary:hover {
		background: #e5e7eb;
	}

	.quiz-area {
		max-width: 600px;
		margin: 0 auto;
	}

	.score-board {
		display: flex;
		justify-content: center;
		gap: 2rem;
		padding: 1.5rem;
		background: #f8f9fa;
		border-radius: 8px;
		margin-bottom: 2rem;
	}

	.score-item {
		display: flex;
		flex-direction: column;
		align-items: center;
	}

	.score-item .label {
		font-size: 0.9rem;
		color: #666;
		margin-bottom: 0.25rem;
	}

	.score-item .value {
		font-size: 1.5rem;
		font-weight: bold;
		color: #2563eb;
	}

	.quiz-card {
		background: #fff;
		border-radius: 12px;
		padding: 2rem;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
		transition: all 0.3s;
	}

	.quiz-card.correct {
		border: 3px solid #10b981;
		background: #f0fdf4;
	}

	.quiz-card.incorrect {
		border: 3px solid #ef4444;
		background: #fef2f2;
	}

	.word-display {
		text-align: center;
		margin-bottom: 2rem;
	}

	.word-display .label {
		font-size: 0.9rem;
		color: #666;
		margin-bottom: 0.5rem;
	}

	.dutch-word {
		font-size: 2.5rem;
		color: #333;
		margin: 0;
		font-weight: bold;
	}

	.answer-input {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.answer-input input {
		padding: 1rem;
		border: 2px solid #d1d5db;
		border-radius: 8px;
		font-size: 1.1rem;
		text-align: center;
	}

	.answer-input input:focus {
		outline: none;
		border-color: #2563eb;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
	}

	.feedback {
		text-align: center;
		padding: 1rem;
	}

	.feedback .icon {
		font-size: 3rem;
		margin: 0;
	}

	.feedback .message {
		font-size: 1.1rem;
		margin: 0.5rem 0 0 0;
	}

	.correct-feedback .icon {
		color: #10b981;
	}

	.correct-feedback .message {
		color: #059669;
	}

	.incorrect-feedback .icon {
		color: #ef4444;
	}

	.incorrect-feedback .message {
		color: #dc2626;
	}

	.quiz-actions {
		margin-top: 2rem;
		text-align: center;
	}

	.empty {
		color: #999;
		font-style: italic;
		text-align: center;
		margin-top: 2rem;
	}
</style>
