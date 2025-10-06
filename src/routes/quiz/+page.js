import { getSupabase } from '$lib/supabase';

export async function load() {
	const supabase = getSupabase();

	const { data: collections, error } = await supabase
		.from('collections')
		.select(`
			id,
			name,
			words (
				id,
				dutch,
				translation
			)
		`)
		.order('created_at', { ascending: false });

	if (error) {
		console.error('Error loading collections:', error);
		return { collections: [] };
	}

	return { collections };
}
