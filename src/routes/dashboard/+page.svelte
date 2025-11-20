<script>
	let { data } = $props();

	function formatDate(dateString) {
		const date = new Date(dateString);
		return date.toLocaleDateString('en-US', {
			month: 'short',
			day: 'numeric',
			year: 'numeric',
			hour: '2-digit',
			minute: '2-digit'
		});
	}

	function formatDuration(seconds) {
		const mins = Math.floor(seconds / 60);
		const secs = seconds % 60;
		if (mins > 0) {
			return `${mins}m ${secs}s`;
		}
		return `${secs}s`;
	}

	function getPerformanceColor(percentage) {
		if (percentage >= 80) return '#10b981';
		if (percentage >= 60) return '#f59e0b';
		return '#ef4444';
	}
</script>

<svelte:head>
	<title>Progress Dashboard - VocabMaster</title>
	<meta name="description" content="Track your learning progress and quiz performance" />
</svelte:head>

<div class="container">
	<h1>Quiz Dashboard</h1>

	{#if data?.quizResults && data.quizResults.length > 0}
		<div class="stats-overview">
			<div class="stat-card">
				<span class="stat-label">Total Quizzes</span>
				<span class="stat-value">{data.quizResults.length}</span>
			</div>
			<div class="stat-card">
				<span class="stat-label">Average Score</span>
				<span class="stat-value">
					{Math.round(data.quizResults.reduce((sum, r) => sum + r.percentage, 0) / data.quizResults.length)}%
				</span>
			</div>
			<div class="stat-card">
				<span class="stat-label">Best Score</span>
				<span class="stat-value">
					{Math.max(...data.quizResults.map(r => r.percentage))}%
				</span>
			</div>
			<div class="stat-card">
				<span class="stat-label">Total Questions</span>
				<span class="stat-value">
					{data.quizResults.reduce((sum, r) => sum + r.total_questions, 0)}
				</span>
			</div>
		</div>

		<div class="results-section">
			<h2>Recent Quizzes</h2>
			<div class="results-list">
				{#each data.quizResults as result}
					<div class="result-card">
						<div class="result-header">
							<h3>{result.collections?.name || 'Unknown Collection'}</h3>
							<span class="result-date">{formatDate(result.created_at)}</span>
						</div>
						<div class="result-body">
							<div class="result-score">
								<div
									class="score-circle"
									style="border-color: {getPerformanceColor(result.percentage)}"
								>
									<span class="score-percentage" style="color: {getPerformanceColor(result.percentage)}">
										{result.percentage}%
									</span>
								</div>
								<div class="score-details">
									<p class="score-text">{result.score} / {result.total_questions} correct</p>
									<p class="duration-text">Duration: {formatDuration(result.duration_seconds)}</p>
								</div>
							</div>
							<div class="performance-bar">
								<div
									class="performance-fill"
									style="width: {result.percentage}%; background-color: {getPerformanceColor(result.percentage)}"
								></div>
							</div>
						</div>
					</div>
				{/each}
			</div>
		</div>
	{:else}
		<div class="empty-state">
			<p>No quiz results yet.</p>
			<p class="empty-hint">Take a quiz to see your results here!</p>
			<a href="/quiz" class="btn-primary">Start a Quiz</a>
		</div>
	{/if}
</div>

<style>
	.container {
		padding: 3rem 2rem;
		max-width: 1200px;
		margin: 0 auto;
		min-height: calc(100vh - 200px);
	}

	h1 {
		text-align: center;
		color: #1f2937;
		font-size: 2.5rem;
		font-weight: 800;
		margin-bottom: 3rem;
	}

	h2 {
		color: #1f2937;
		margin-bottom: 2rem;
		font-size: 1.875rem;
		font-weight: 700;
	}

	.stats-overview {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1.5rem;
		margin-bottom: 3rem;
	}

	.stat-card {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		padding: 2.5rem;
		border-radius: 16px;
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 0.75rem;
		box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
		transition: all 0.3s;
	}

	.stat-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 12px 32px rgba(102, 126, 234, 0.4);
	}

	.stat-label {
		font-size: 0.9rem;
		opacity: 0.9;
	}

	.stat-value {
		font-size: 2.5rem;
		font-weight: bold;
	}

	.results-section {
		margin-top: 2rem;
	}

	.results-list {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.result-card {
		background: white;
		border: 2px solid #e5e7eb;
		border-radius: 16px;
		padding: 2rem;
		box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
		transition: all 0.3s;
	}

	.result-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 12px 24px rgba(102, 126, 234, 0.15);
		border-color: #667eea;
	}

	.result-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 1.5rem;
		gap: 1rem;
		flex-wrap: wrap;
	}

	.result-header h3 {
		margin: 0;
		color: #1f2937;
		font-size: 1.25rem;
		font-weight: 700;
	}

	.result-date {
		color: #666;
		font-size: 0.9rem;
	}

	.result-body {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.result-score {
		display: flex;
		align-items: center;
		gap: 1.5rem;
	}

	.score-circle {
		width: 80px;
		height: 80px;
		border-radius: 50%;
		border: 4px solid;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
	}

	.score-percentage {
		font-size: 1.5rem;
		font-weight: bold;
	}

	.score-details {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}

	.score-text {
		margin: 0;
		font-size: 1.1rem;
		color: #333;
		font-weight: 500;
	}

	.duration-text {
		margin: 0;
		font-size: 0.9rem;
		color: #666;
	}

	.performance-bar {
		width: 100%;
		height: 8px;
		background: #e5e7eb;
		border-radius: 4px;
		overflow: hidden;
	}

	.performance-fill {
		height: 100%;
		transition: width 0.3s;
		border-radius: 4px;
	}

	.empty-state {
		text-align: center;
		padding: 4rem 2rem;
	}

	.empty-state p {
		color: #666;
		font-size: 1.1rem;
		margin-bottom: 0.5rem;
	}

	.empty-hint {
		color: #999;
		font-size: 0.95rem;
		margin-bottom: 2rem;
	}

	.btn-primary {
		display: inline-block;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		border: none;
		padding: 0.875rem 1.75rem;
		border-radius: 8px;
		font-size: 1rem;
		font-weight: 700;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.3s;
		box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
	}

	.btn-primary:hover {
		transform: translateY(-2px);
		box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
	}
</style>
