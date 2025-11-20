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
	<title>Sign In - VocabMaster</title>
</svelte:head>

<div class="auth-page">
	<div class="auth-container">
		<div class="auth-header">
			<h1>Welcome Back</h1>
			<p class="subtitle">Sign in to continue your language learning journey</p>
		</div>

		<form class="auth-form" onsubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
			<div class="form-group">
				<label for="email">Email Address</label>
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
				<div class="alert alert-error">{errorMessage}</div>
			{/if}

			<button type="submit" class="btn-primary btn-large" disabled={isSubmitting}>
				{isSubmitting ? 'Signing in...' : 'Sign In'}
			</button>
		</form>

		<div class="auth-footer">
			<p>
				Don't have an account? <a href="/register">Create one now</a>
			</p>
			<p>
				<a href="/forgot-password">Forgot your password?</a>
			</p>
		</div>
	</div>
</div>

<style>
	.auth-page {
		min-height: calc(100vh - 200px);
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 2rem;
		background: linear-gradient(135deg, #f9fafb 0%, #e5e7eb 100%);
	}

	.auth-container {
		background: white;
		border-radius: 16px;
		padding: 3rem;
		max-width: 480px;
		width: 100%;
		box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
	}

	.auth-header {
		text-align: center;
		margin-bottom: 2.5rem;
	}

	h1 {
		margin: 0 0 0.75rem 0;
		color: #1f2937;
		font-size: 2.25rem;
		font-weight: 800;
	}

	.subtitle {
		color: #6b7280;
		font-size: 1.05rem;
		margin: 0;
		line-height: 1.6;
	}

	.auth-form {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.form-group {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	label {
		color: #374151;
		font-weight: 600;
		font-size: 0.95rem;
	}

	input {
		padding: 0.875rem 1rem;
		border: 2px solid #e5e7eb;
		border-radius: 8px;
		font-size: 1rem;
		transition: all 0.2s;
		background: #f9fafb;
	}

	input:hover {
		border-color: #d1d5db;
	}

	input:focus {
		outline: none;
		border-color: #667eea;
		box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
		background: white;
	}

	.alert {
		padding: 0.875rem 1rem;
		border-radius: 8px;
		font-size: 0.95rem;
		font-weight: 500;
	}

	.alert-error {
		color: #991b1b;
		background: #fee2e2;
		border: 1px solid #fecaca;
	}

	.btn-primary {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		border: none;
		padding: 1rem 2rem;
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

	.btn-large {
		padding: 1.125rem 2rem;
		font-size: 1.05rem;
	}

	.auth-footer {
		margin-top: 2rem;
		text-align: center;
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.auth-footer p {
		margin: 0;
		color: #6b7280;
		font-size: 0.95rem;
	}

	.auth-footer a {
		color: #667eea;
		text-decoration: none;
		font-weight: 600;
		transition: color 0.2s;
	}

	.auth-footer a:hover {
		color: #764ba2;
		text-decoration: underline;
	}

	@media (max-width: 640px) {
		.auth-container {
			padding: 2rem 1.5rem;
		}

		h1 {
			font-size: 1.875rem;
		}

		.subtitle {
			font-size: 1rem;
		}
	}
</style>
