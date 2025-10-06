<script>
	/** @type {{data: any}} */
	let { data } = $props();
</script>

<svelte:head>
	<title>Collections</title>
	<meta name="description" content="Added collections" />
</svelte:head>

<div class="container">
	<h1>Collections</h1>

	{#if data?.data?.collections}
		<div class="collections-grid">
			{#each data.data.collections as collection}
				<div class="collection-card">
					<h2>{collection.name}</h2>
					{#if collection.words && collection.words.length > 0}
						<p class="word-count">{collection.words.length} word{collection.words.length !== 1 ? 's' : ''}</p>
						<ul>
							{#each collection.words as word}
								<li>
									<strong>{word.dutch}</strong> - {word.translation}
								</li>
							{/each}
						</ul>
					{:else}
						<p class="empty">No words yet</p>
					{/if}
				</div>
			{/each}
		</div>
	{:else}
		<p class="empty">No collections found</p>
	{/if}
</div>

<style>
	.container {
		padding: 2rem;
		max-width: 1200px;
		margin: 0 auto;
	}

	h1 {
		margin-bottom: 2rem;
		color: #333;
	}

	.collections-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
		gap: 1.5rem;
	}

	.collection-card {
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 8px;
		padding: 1.5rem;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
		transition: box-shadow 0.2s;
	}

	.collection-card:hover {
		box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
	}

	h2 {
		margin: 0 0 0.5rem 0;
		color: #333;
		font-size: 1.5rem;
	}

	.word-count {
		color: #666;
		font-size: 0.9rem;
		margin-bottom: 1rem;
	}

	ul {
		list-style: none;
		padding: 0;
		margin: 0;
	}

	li {
		padding: 0.5rem;
		margin: 0.5rem 0;
		background: #f5f5f5;
		border-radius: 4px;
		font-size: 0.9rem;
	}

	.empty {
		color: #999;
		font-style: italic;
	}
</style>