import { getSupabase } from '$lib/supabase';
import { redirect } from '@sveltejs/kit';

export async function load() {
	const supabase = getSupabase();

	const { data: { session } } = await supabase.auth.getSession();

	if (!session) {
		throw redirect(303, '/login');
	}

	const { data: collections, error } = await supabase
		.from('collections')
		.select(`
			id,
			name,
			created_at,
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
