import { writable } from 'svelte/store';
import { supabase } from '$lib/supabase';
import { goto } from '$app/navigation';

export const user = writable(null);
export const loading = writable(true);

export async function initAuth() {
	loading.set(true);

	const { data: { session } } = await supabase.auth.getSession();
	user.set(session?.user ?? null);
	loading.set(false);

	supabase.auth.onAuthStateChange((_event, session) => {
		(async () => {
			user.set(session?.user ?? null);
		})();
	});
}

export async function signUp(email, password) {
	const { data, error } = await supabase.auth.signUp({
		email,
		password
	});

	if (error) throw error;
	return data;
}

export async function signIn(email, password) {
	const { data, error } = await supabase.auth.signInWithPassword({
		email,
		password
	});

	if (error) throw error;
	return data;
}

export async function signOut() {
	const { error } = await supabase.auth.signOut();
	if (error) throw error;
	user.set(null);
	goto('/login');
}

export async function resetPasswordForEmail(email) {
	const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
		redirectTo: `${window.location.origin}/reset-password`
	});

	if (error) throw error;
	return data;
}

export async function updatePassword(newPassword) {
	const { data, error } = await supabase.auth.updateUser({
		password: newPassword
	});

	if (error) throw error;
	return data;
}
