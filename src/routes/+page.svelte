<script>
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
