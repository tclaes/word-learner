<script>
	import { signIn, signInWithGoogle } from '$lib/stores/auth';
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

	async function handleGoogleSignIn() {
		isSubmitting = true;
		errorMessage = '';

		try {
			await signInWithGoogle();
		} catch (error) {
			errorMessage = error.message || 'Failed to sign in with Google';
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

		<button type="button" class="btn-google" onclick={handleGoogleSignIn} disabled={isSubmitting}>
			<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20">
				<path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
				<path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
				<path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
				<path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
			</svg>
			Continue with Google
		</button>

		<div class="divider">
			<span>or</span>
		</div>

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

	.btn-google {
		width: 100%;
		background: white;
		color: #3c4043;
		border: 1px solid #dadce0;
		padding: 0.875rem;
		border-radius: 6px;
		font-size: 1rem;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.2s;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.75rem;
		margin-bottom: 1.5rem;
	}

	.btn-google:hover:not(:disabled) {
		background: #f8f9fa;
		box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
	}

	.btn-google:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.btn-google svg {
		flex-shrink: 0;
	}

	.divider {
		position: relative;
		text-align: center;
		margin: 1.5rem 0;
	}

	.divider::before {
		content: '';
		position: absolute;
		top: 50%;
		left: 0;
		right: 0;
		height: 1px;
		background: #d1d5db;
	}

	.divider span {
		position: relative;
		background: white;
		padding: 0 1rem;
		color: #666;
		font-size: 0.9rem;
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
