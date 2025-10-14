<script>
	import { user } from '$lib/stores/auth';

	/** @type {{data: any}} */
	let { data } = $props();
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Woorden leren app" />
</svelte:head>

<section>
	<h1>Oefen nieuwe woorden</h1>

	<p>Maak een nieuwe collectie woorden en speel de quiz om de vertaling in te oefenen</p>

	{#if !$user}
		<div class="cta">
			<p class="cta-text">Sign in to start managing your vocabulary collections</p>
			<div class="cta-buttons">
				<a href="/login" class="btn-primary">Sign In</a>
				<a href="/register" class="btn-secondary">Create Account</a>
			</div>
		</div>
	{:else}
		<div class="cta">
			<p class="cta-text">Welcome back! Ready to practice?</p>
			<div class="cta-buttons">
				<a href="/collections" class="btn-primary">My Collections</a>
				<a href="/quiz" class="btn-secondary">Start Quiz</a>
			</div>
		</div>
	{/if}
</section>

<style>
	section {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		flex: 0.6;
	}

	h1 {
		width: 100%;
	}

	.collection {
		margin: 2rem 0;
		width: 100%;
	}

	h2 {
		color: #333;
		margin-bottom: 1rem;
	}

	ul {
		list-style: none;
		padding: 0;
	}

	li {
		padding: 0.5rem;
		margin: 0.5rem 0;
		background: #f5f5f5;
		border-radius: 4px;
	}

	.cta {
		margin-top: 3rem;
		text-align: center;
		width: 100%;
	}

	.cta-text {
		font-size: 1.2rem;
		color: #666;
		margin-bottom: 1.5rem;
	}

	.cta-buttons {
		display: flex;
		gap: 1rem;
		justify-content: center;
		flex-wrap: wrap;
	}

	.btn-primary {
		background: #2563eb;
		color: white;
		border: none;
		padding: 0.875rem 1.75rem;
		border-radius: 6px;
		font-size: 1rem;
		font-weight: 600;
		text-decoration: none;
		cursor: pointer;
		transition: background 0.2s;
	}

	.btn-primary:hover {
		background: #1d4ed8;
	}

	.btn-secondary {
		background: #f3f4f6;
		color: #374151;
		border: 2px solid #d1d5db;
		padding: 0.875rem 1.75rem;
		border-radius: 6px;
		font-size: 1rem;
		font-weight: 600;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-secondary:hover {
		background: #e5e7eb;
		border-color: #9ca3af;
	}
</style>
