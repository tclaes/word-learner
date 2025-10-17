<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { updatePassword } from '$lib/stores/auth';
	import { supabase } from '$lib/supabase';

	let password = $state('');
	let confirmPassword = $state('');
	let isSubmitting = $state(false);
	let errorMessage = $state('');
	let successMessage = $state('');
	let hasSession = $state(false);
	let isCheckingSession = $state(true);

	onMount(() => {
		(async () => {
			const { data: { session } } = await supabase.auth.getSession();
			hasSession = !!session;
			isCheckingSession = false;

			if (!session) {
				errorMessage = 'Invalid or expired reset link. Please request a new password reset.';
			}
		})();
	});

	async function handleSubmit() {
		if (!password.trim() || !confirmPassword.trim()) {
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
			await updatePassword(password);
			successMessage = 'Password updated successfully! Redirecting to login...';
			setTimeout(() => {
				goto('/login');
			}, 2000);
		} catch (error) {
			errorMessage = error.message || 'Failed to update password';
		} finally {
			isSubmitting = false;
		}
	}
</script>

<svelte:head>
	<title>Reset Password</title>
</svelte:head>

<div class="container">
	<div class="auth-card">
		<h1>Set New Password</h1>
		<p class="subtitle">Enter your new password below</p>

		{#if isCheckingSession}
			<p class="info">Verifying reset link...</p>
		{:else if !hasSession}
			<p class="error">{errorMessage}</p>
			<a href="/forgot-password" class="btn-secondary">Request New Reset Link</a>
		{:else}
			<form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
				<div class="form-group">
					<label for="password">New Password</label>
					<input
						id="password"
						type="password"
						bind:value={password}
						placeholder="At least 6 characters"
						required
					/>
				</div>

				<div class="form-group">
					<label for="confirm-password">Confirm New Password</label>
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
					{isSubmitting ? 'Updating...' : 'Update Password'}
				</button>
			</form>
		{/if}
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

	.info {
		color: #2563eb;
		font-size: 0.95rem;
		text-align: center;
		padding: 1rem;
		background: #eff6ff;
		border-radius: 6px;
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
		line-height: 1.5;
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

	.btn-secondary {
		display: block;
		background: #f3f4f6;
		color: #374151;
		border: 2px solid #d1d5db;
		padding: 0.875rem;
		border-radius: 6px;
		font-size: 1rem;
		font-weight: 600;
		text-decoration: none;
		text-align: center;
		cursor: pointer;
		transition: all 0.2s;
		margin-top: 1rem;
	}

	.btn-secondary:hover {
		background: #e5e7eb;
		border-color: #9ca3af;
	}
</style>
