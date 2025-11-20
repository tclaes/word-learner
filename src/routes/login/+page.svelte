<script>
	import { signIn } from '$lib/stores/auth';
	import { goto } from '$app/navigation';

	let email = $state('');
	let password = $state('');
	let isSubmitting = $state(false);
	let errorMessage = $state('');

	async function handleSubmit() {
		if (!email.trim() || !password.trim()) {
			errorMessage = 'Please enter both email and password';
			return;
		}

		isSubmitting = true;
		errorMessage = '';

		try {
			await signIn(email, password);
			goto('/collections');
		} catch (error) {
			errorMessage = error.message || 'Failed to sign in';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>Login</title>
</svelte:head>

<div class="container">
	<div class="auth-card">
		<h1>Sign In</h1>
		<p class="subtitle">Sign in to access your collections and quizzes</p>

		<form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
			<div class="form-group">
				<label for="email">Email</label>
				<input
					id="email"
					type="email"
					bind:value={email}
					placeholder="your.email@example.com"
					required
				/>
			</div>

			<div class="form-group">
				<label for="password">Password</label>
				<input
					id="password"
					type="password"
					bind:value={password}
					placeholder="Enter your password"
					required
				/>
			</div>

			{#if errorMessage}
				<p class="error">{errorMessage}</p>
			{/if}

			<button type="submit" class="btn-primary" disabled={isSubmitting}>
				{isSubmitting ? 'Signing in...' : 'Sign In'}
			</button>
		</form>

		<div class="auth-links">
			<p class="auth-link">
				Don't have an account? <a href="/register">Create one</a>
			</p>
			<p class="auth-link">
				<a href="/forgot-password">Forgot password?</a>
			</p>
		</div>
	</div>
</div>

<style>
	.container {
		padding: 2rem;
		max-width: 500px;
		margin: 0 auto;
		display: flex;
		justify-content: center;
		align-items: center;
		min-height: calc(100vh - 200px);
	}

	.auth-card {
		background: white;
		border-radius: 12px;
		padding: 2.5rem;
		box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
		width: 100%;
	}

	h1 {
		margin: 0 0 0.5rem 0;
		color: #333;
		font-size: 2rem;
		text-align: center;
	}

	.subtitle {
		color: #666;
		text-align: center;
		margin: 0 0 2rem 0;
		font-size: 0.95rem;
	}

	form {
		display: flex;
		flex-direction: column;
		gap: 1.25rem;
	}

	.form-group {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	label {
		color: #374151;
		font-weight: 500;
		font-size: 0.95rem;
	}

	input {
		padding: 0.75rem;
		border: 1px solid #d1d5db;
		border-radius: 6px;
		font-size: 1rem;
		transition: border-color 0.2s;
	}

	input:focus {
		outline: none;
		border-color: #2563eb;
		box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
	}

	.error {
		color: #ef4444;
		font-size: 0.9rem;
		margin: 0;
		padding: 0.75rem;
		background: #fee;
		border-radius: 6px;
		text-align: center;
	}

	.btn-primary {
		background: #2563eb;
		color: white;
		border: none;
		padding: 0.875rem;
		border-radius: 6px;
		font-size: 1rem;
		font-weight: 600;
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

	.auth-links {
		margin-top: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.auth-link {
		margin: 0;
		text-align: center;
		color: #666;
		font-size: 0.95rem;
	}

	.auth-link a {
		color: #2563eb;
		text-decoration: none;
		font-weight: 600;
	}

	.auth-link a:hover {
		text-decoration: underline;
	}
</style>
