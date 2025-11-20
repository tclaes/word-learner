<script>
	import { signUp } from '$lib/stores/auth';
	import { goto } from '$app/navigation';

	let email = $state('');
	let password = $state('');
	let confirmPassword = $state('');
	let isSubmitting = $state(false);
	let errorMessage = $state('');
	let successMessage = $state('');

	async function handleSubmit() {
		if (!email.trim() || !password.trim() || !confirmPassword.trim()) {
			errorMessage = 'Please fill in all fields';
			return;
		}

		if (password !== confirmPassword) {
			errorMessage = 'Passwords do not match';
			return;
		}

		if (password.length < 6) {
			errorMessage = 'Password must be at least 6 characters';
			return;
		}

		isSubmitting = true;
		errorMessage = '';
		successMessage = '';

		try {
			await signUp(email, password);
			successMessage = 'Account created successfully! Redirecting...';
			setTimeout(() => {
				goto('/collections');
			}, 1500);
		} catch (error) {
			errorMessage = error.message || 'Failed to create account';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>Register</title>
</svelte:head>

<div class="container">
	<div class="auth-card">
		<h1>Create Account</h1>
		<p class="subtitle">Sign up to start managing your vocabulary collections</p>

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
					placeholder="At least 6 characters"
					required
				/>
			</div>

			<div class="form-group">
				<label for="confirm-password">Confirm Password</label>
				<input
					id="confirm-password"
					type="password"
					bind:value={confirmPassword}
					placeholder="Re-enter your password"
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
				{isSubmitting ? 'Creating account...' : 'Create Account'}
			</button>
		</form>

		<p class="auth-link">
			Already have an account? <a href="/login">Sign in</a>
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
