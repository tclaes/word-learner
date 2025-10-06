import { createClient } from '@supabase/supabase-js';
import { browser } from '$app/environment';

let supabaseUrl = '';
let supabaseKey = '';

if (browser) {
	supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
	supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
}

export function getSupabase() {
	if (!browser) {
		return createClient(
			process.env.VITE_SUPABASE_URL || '',
			process.env.VITE_SUPABASE_ANON_KEY || ''
		);
	}
	return createClient(supabaseUrl, supabaseKey);
}

export const supabase = browser ? getSupabase() : null;
