<script>
	/** @type {{data: any}} */
	let { data } = $props();
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<section>
	<h1>Language word learner</h1>

	{#if data?.data?.collections}
		{#each data.data.collections as collection}
			<div class="collection">
				<h2>{collection.name}</h2>
				{#if collection.words && collection.words.length > 0}
					<ul>
						{#each collection.words as word}
							<li>
								<strong>{word.dutch}</strong> - {word.translation}
							</li>
						{/each}
					</ul>
				{/if}
			</div>
		{/each}
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
</style>
