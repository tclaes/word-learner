<script>
	import { resetPasswordForEmail } from '$lib/stores/auth';

	let email = $state('');
	let isSubmitting = $state(false);
	let errorMessage = $state('');
	let successMessage = $state('');

	async function handleSubmit() {
		if (!email.trim()) {
			errorMessage = 'Please enter your email address';
			return;
		}

		isSubmitting = true;
		errorMessage = '';
		successMessage = '';

		try {
			await resetPasswordForEmail(email);
			successMessage = 'Password reset email sent! Check your inbox for the reset link.';
			email = '';
		} catch (error) {
			errorMessage = error.message || 'Failed to send reset email';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>Forgot Password</title>
</svelte:head>

<div class="container">
	<div class="auth-card">
		<h1>Reset Password</h1>
		<p class="subtitle">Enter your email address and we'll send you a link to reset your password</p>

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

			{#if errorMessage}
				<p class="error">{errorMessage}</p>
			{/if}

			{#if successMessage}
				<p class="success">{successMessage}</p>
			{/if}

			<button type="submit" class="btn-primary" disabled={isSubmitting}>
				{isSubmitting ? 'Sending...' : 'Send Reset Link'}
			</button>
		</form>

		<p class="auth-link">
			Remember your password? <a href="/login">Sign in</a>
		</p>
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
		line-height: 1.5;
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

	.success {
		color: #10b981;
		font-size: 0.9rem;
		margin: 0;
		padding: 0.75rem;
		background: #d1fae5;
		border-radius: 6px;
		text-align: center;
		line-height: 1.5;
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

	.auth-link {
		margin: 1.5rem 0 0 0;
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
