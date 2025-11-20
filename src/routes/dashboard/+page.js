import { supabase } from '$lib/supabase';

export async function load() {
	const { data: { session } } = await supabase.auth.getSession();

	if (!session) {
		return {
			quizResults: []
		};
	}

	const { data: quizResults, error } = await supabase
		.from('quiz_scores')
		.select(`
			*,
			collections (
				name
			)
		`)
		.eq('user_id', session.user.id)
		.order('created_at', { ascending: false });

	if (error) {
		console.error('Error fetching quiz results:', error);
		return {
			quizResults: []
		};
	}

	return {
		quizResults: quizResults || []
	};
}
