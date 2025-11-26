<script>
	import { page } from '$app/state';
	import { user, signOut } from '$lib/stores/auth';
</script>

<header>
	<div class="logo">
		<a href="/">
			<span class="logo-icon">📚</span>
			<span class="logo-text">VocabMaster</span>
		</a>
	</div>

	<nav>
		<ul>
			<li aria-current={page.url.pathname === '/' ? 'page' : undefined}>
				<a href="/">Home</a>
			</li>
			<li aria-current={page.url.pathname.startsWith('/collections') ? 'page' : undefined}>
				<a href="/collections">Collections</a>
			</li>
			<li aria-current={page.url.pathname.startsWith('/quiz') ? 'page' : undefined}>
				<a href="/quiz">Quiz</a>
			</li>
			{#if $user}
				<li aria-current={page.url.pathname === '/dashboard' ? 'page' : undefined}>
					<a href="/dashboard">Dashboard</a>
				</li>
			{/if}
			<li aria-current={page.url.pathname === '/about' ? 'page' : undefined}>
				<a href="/about">About</a>
			</li>
		</ul>
	</nav>

	<div class="auth-section">
		{#if $user}
			<span class="user-email">{$user.email}</span>
			<button class="btn-signout" onclick={signOut}>Sign Out</button>
		{:else}
			<a href="/login" class="btn-login">Sign In</a>
			<a href="/register" class="btn-register">Get Started</a>
		{/if}
	</div>
</header>

<style>
	header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 1rem 2rem;
		background: white;
		border-bottom: 1px solid #e5e7eb;
		box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	}

	.logo a {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		text-decoration: none;
		transition: transform 0.2s;
	}

	.logo a:hover {
		transform: translateY(-2px);
	}

	.logo-icon {
		font-size: 1.75rem;
	}

	.logo-text {
		font-size: 1.25rem;
		font-weight: 800;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	nav {
		flex: 1;
		display: flex;
		justify-content: center;
	}

	ul {
		display: flex;
		gap: 0.5rem;
		list-style: none;
		padding: 0;
		margin: 0;
		align-items: center;
	}

	li {
		position: relative;
	}

	li[aria-current='page'] a {
		color: #667eea;
		background: rgba(102, 126, 234, 0.1);
	}

	nav a {
		display: block;
		padding: 0.625rem 1rem;
		color: #374151;
		font-weight: 600;
		font-size: 0.95rem;
		text-decoration: none;
		border-radius: 8px;
		transition: all 0.2s;
	}

	nav a:hover {
		color: #667eea;
		background: rgba(102, 126, 234, 0.05);
	}

	.auth-section {
		display: flex;
		align-items: center;
		gap: 0.75rem;
	}

	.user-email {
		font-size: 0.875rem;
		color: #6b7280;
		max-width: 150px;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.btn-login {
		background: white;
		color: #667eea;
		border: 2px solid #667eea;
		padding: 0.5rem 1.25rem;
		border-radius: 8px;
		font-size: 0.95rem;
		font-weight: 600;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-login:hover {
		background: #667eea;
		color: white;
	}

	.btn-register {
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		border: none;
		padding: 0.5rem 1.25rem;
		border-radius: 8px;
		font-size: 0.95rem;
		font-weight: 600;
		text-decoration: none;
		cursor: pointer;
		transition: all 0.2s;
		box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
	}

	.btn-register:hover {
		transform: translateY(-1px);
		box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
	}

	.btn-signout {
		background: #f3f4f6;
		color: #374151;
		border: 2px solid #e5e7eb;
		padding: 0.5rem 1.25rem;
		border-radius: 8px;
		font-size: 0.95rem;
		font-weight: 600;
		cursor: pointer;
		transition: all 0.2s;
	}

	.btn-signout:hover {
		background: #e5e7eb;
		border-color: #d1d5db;
	}

	@media (max-width: 768px) {
		header {
			padding: 1rem;
			flex-wrap: wrap;
		}

		.logo {
			flex: 1;
		}

		nav {
			order: 3;
			width: 100%;
			margin-top: 1rem;
			justify-content: flex-start;
			overflow-x: auto;
		}

		ul {
			gap: 0.25rem;
		}

		nav a {
			padding: 0.5rem 0.75rem;
			font-size: 0.875rem;
			white-space: nowrap;
		}

		.auth-section {
			gap: 0.5rem;
		}

		.user-email {
			display: none;
		}

		.btn-login,
		.btn-register,
		.btn-signout {
			padding: 0.5rem 1rem;
			font-size: 0.875rem;
		}
	}
</style>
