<script>
	import { supabase } from '$lib/supabase';
	import { user } from '$lib/stores/auth';
	import { goto } from '$app/navigation';
	import { onDestroy } from 'svelte';

	let { data } = $props();

	let selectedCollection = $state(null);
	let quizStarted = $state(false);
	let quizEnded = $state(false);
	let currentWord = $state(null);
	let userAnswer = $state('');
	let score = $state(0);
	let totalAnswered = $state(0);
	let feedback = $state('');
	let usedWords = $state([]);
	let quizDirection = $state('dutch-to-translation');
	let timeRemaining = $state(300);
	let timerInterval = null;
	let quizStartTime = $state(null);

	onDestroy(() => {
		if (timerInterval) {
			clearInterval(timerInterval);
		}
	});

	function selectCollection(collection) {
		selectedCollection = collection;
		quizStarted = false;
		quizEnded = false;
		resetQuiz();
	}

	function startQuiz() {
		if (!selectedCollection || !selectedCollection.words || selectedCollection.words.length === 0) {
			return;
		}
		quizStarted = true;
		quizEnded = false;
		resetQuiz();
		quizStartTime = Date.now();
		timeRemaining = 300;
		startTimer();
		nextWord();
	}

	function startTimer() {
		if (timerInterval) {
			clearInterval(timerInterval);
		}
		timerInterval = setInterval(() => {
			timeRemaining--;
			if (timeRemaining <= 0) {
				endQuiz();
			}
		}, 1000);
	}

	function resetQuiz() {
		score = 0;
		totalAnswered = 0;
		feedback = '';
		usedWords = [];
		userAnswer = '';
		currentWord = null;
		timeRemaining = 300;
		if (timerInterval) {
			clearInterval(timerInterval);
			timerInterval = null;
		}
	}

	function nextWord() {
		if (!selectedCollection || !selectedCollection.words) return;

		const availableWords = selectedCollection.words.filter(
			word => !usedWords.includes(word.id)
		);

		if (availableWords.length === 0) {
			endQuiz();
			return;
		}

		const randomIndex = Math.floor(Math.random() * availableWords.length);
		currentWord = availableWords[randomIndex];

		userAnswer = '';
		feedback = '';
	}

	function checkAnswer() {
		if (!currentWord || !userAnswer.trim()) return;

		totalAnswered++;

		const correctAnswer = quizDirection === 'dutch-to-translation'
			? currentWord.translation.toLowerCase().trim()
			: currentWord.dutch.toLowerCase().trim();
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

	async function endQuiz() {
		if (timerInterval) {
			clearInterval(timerInterval);
			timerInterval = null;
		}

		quizStarted = false;
		quizEnded = true;

		const percentage = totalAnswered > 0 ? Math.round((score / totalAnswered) * 100) : 0;
		const duration = quizStartTime ? Math.round((Date.now() - quizStartTime) / 1000) : 0;

		await saveQuizResult(percentage, duration);
	}

	async function saveQuizResult(percentage, duration) {
		if (!$user || !selectedCollection) return;

		try {
			const { error } = await supabase
				.from('quiz_scores')
				.insert({
					user_id: $user.id,
					collection_id: selectedCollection.id,
					score: score,
					total_questions: totalAnswered,
					percentage: percentage,
					duration_seconds: duration
				});

			if (error) {
				console.error('Error saving quiz result:', error);
			}
		} catch (err) {
			console.error('Error saving quiz result:', err);
		}
	}

	function handleKeyPress(event) {
		if (event.key === 'Enter') {
			checkAnswer();
		}
	}

	function getQuestionWord() {
		if (!currentWord) return '';
		return quizDirection === 'dutch-to-translation' ? currentWord.dutch : currentWord.translation;
	}

	function getCorrectAnswer() {
		if (!currentWord) return '';
		return quizDirection === 'dutch-to-translation' ? currentWord.translation : currentWord.dutch;
	}

	function getQuestionLabel() {
		return quizDirection === 'dutch-to-translation' ? 'Translate this word:' : 'Give the Dutch word for:';
	}

	function formatTime(seconds) {
		const mins = Math.floor(seconds / 60);
		const secs = seconds % 60;
		return `${mins}:${secs.toString().padStart(2, '0')}`;
	}

	function formatDuration(seconds) {
		const mins = Math.floor(seconds / 60);
		const secs = seconds % 60;
		if (mins > 0) {
			return `${mins}m ${secs}s`;
		}
		return `${secs}s`;
	}

	function restartQuiz() {
		quizEnded = false;
		startQuiz();
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
	{:else if quizEnded}
		<div class="quiz-results">
			<h2>Quiz Complete!</h2>
			<div class="results-card">
				<div class="result-item main-score">
					<span class="result-label">Final Score</span>
					<span class="result-value large">{score} / {totalAnswered}</span>
				</div>
				<div class="result-item">
					<span class="result-label">Accuracy</span>
					<span class="result-value">{totalAnswered > 0 ? Math.round((score / totalAnswered) * 100) : 0}%</span>
				</div>
				<div class="result-item">
					<span class="result-label">Duration</span>
					<span class="result-value">{formatDuration(quizStartTime ? Math.round((Date.now() - quizStartTime) / 1000) : 0)}</span>
				</div>
				<div class="result-item">
					<span class="result-label">Collection</span>
					<span class="result-value">{selectedCollection.name}</span>
				</div>
			</div>
			<div class="button-group">
				<button class="btn-secondary" onclick={() => { selectedCollection = null; quizEnded = false; }}>
					Choose Different Collection
				</button>
				<button class="btn-primary" onclick={restartQuiz}>
					Try Again
				</button>
				<button class="btn-primary" onclick={() => goto('/dashboard')}>
					View All Results
				</button>
			</div>
		</div>
	{:else if !quizStarted}
		<div class="quiz-setup">
			<h2>Ready to start?</h2>
			<p class="collection-name">Collection: <strong>{selectedCollection.name}</strong></p>
			<p class="word-count">
				{selectedCollection.words?.length || 0} word{selectedCollection.words?.length !== 1 ? 's' : ''}
			</p>
			<p class="quiz-info">The quiz will end after all words are tested or after 5 minutes.</p>

			<div class="direction-selection">
				<label class="direction-label">Quiz Direction:</label>
				<div class="direction-buttons">
					<button
						class="direction-btn"
						class:active={quizDirection === 'dutch-to-translation'}
						onclick={() => quizDirection = 'dutch-to-translation'}
					>
						Dutch → Translation
					</button>
					<button
						class="direction-btn"
						class:active={quizDirection === 'translation-to-dutch'}
						onclick={() => quizDirection = 'translation-to-dutch'}
					>
						Translation → Dutch
					</button>
				</div>
			</div>

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
					<span class="label">Time</span>
					<span class="value" class:warning={timeRemaining < 60}>{formatTime(timeRemaining)}</span>
				</div>
				<div class="score-item">
					<span class="label">Score</span>
					<span class="value">{score} / {totalAnswered}</span>
				</div>
				<div class="score-item">
					<span class="label">Progress</span>
					<span class="value">{usedWords.length} / {selectedCollection.words?.length || 0}</span>
				</div>
				{#if totalAnswered > 0}
					<div class="score-item">
						<span class="label">Accuracy</span>
						<span class="value">{Math.round((score / totalAnswered) * 100)}%</span>
					</div>
				{/if}
			</div>

			{#if currentWord}
				<div class="quiz-card" class:correct={feedback === 'correct'} class:incorrect={feedback === 'incorrect'}>
					<div class="word-display">
						<p class="label">{getQuestionLabel()}</p>
						<h2 class="dutch-word">{getQuestionWord()}</h2>
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
							<p class="message">Incorrect. The answer was: <strong>{getCorrectAnswer()}</strong></p>
						</div>
					{/if}
				</div>
			{/if}

			<div class="quiz-actions">
				<button class="btn-secondary" onclick={endQuiz}>
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

	.quiz-info {
		font-size: 0.95rem;
		color: #2563eb;
		margin: 1rem 0;
		font-style: italic;
	}

	.direction-selection {
		margin: 2rem 0;
	}

	.direction-label {
		display: block;
		font-size: 1rem;
		color: #333;
		margin-bottom: 0.75rem;
		font-weight: 500;
	}

	.direction-buttons {
		display: flex;
		gap: 0.75rem;
		justify-content: center;
	}

	.direction-btn {
		background: #f3f4f6;
		color: #374151;
		border: 2px solid #d1d5db;
		padding: 0.75rem 1.5rem;
		border-radius: 6px;
		font-size: 0.95rem;
		cursor: pointer;
		transition: all 0.2s;
	}

	.direction-btn:hover {
		background: #e5e7eb;
		border-color: #9ca3af;
	}

	.direction-btn.active {
		background: #2563eb;
		color: white;
		border-color: #2563eb;
	}

	.direction-btn.active:hover {
		background: #1d4ed8;
		border-color: #1d4ed8;
	}

	.button-group {
		display: flex;
		gap: 1rem;
		justify-content: center;
		margin-top: 2rem;
		flex-wrap: wrap;
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
		gap: 1.5rem;
		padding: 1.5rem;
		background: #f8f9fa;
		border-radius: 8px;
		margin-bottom: 2rem;
		flex-wrap: wrap;
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

	.score-item .value.warning {
		color: #ef4444;
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

	.quiz-results {
		text-align: center;
		padding: 2rem;
		background: #fff;
		border-radius: 12px;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
	}

	.quiz-results h2 {
		color: #333;
		margin-bottom: 2rem;
		font-size: 2rem;
	}

	.results-card {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1.5rem;
		margin: 2rem 0;
	}

	.result-item {
		padding: 1.5rem;
		background: #f8f9fa;
		border-radius: 8px;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.result-item.main-score {
		grid-column: 1 / -1;
		background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
		color: white;
	}

	.result-label {
		font-size: 0.9rem;
		color: #666;
		font-weight: 500;
	}

	.main-score .result-label {
		color: rgba(255, 255, 255, 0.9);
	}

	.result-value {
		font-size: 1.5rem;
		font-weight: bold;
		color: #333;
	}

	.result-value.large {
		font-size: 2.5rem;
	}

	.main-score .result-value {
		color: white;
	}

	.empty {
		color: #999;
		font-style: italic;
		text-align: center;
		margin-top: 2rem;
	}
</style>
