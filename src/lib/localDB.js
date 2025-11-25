const DB_NAME = 'VocabMasterDB';
const DB_VERSION = 1;
const COLLECTIONS_STORE = 'collections';
const WORDS_STORE = 'words';

let db = null;

function openDB() {
	return new Promise((resolve, reject) => {
		if (db) {
			resolve(db);
			return;
		}

		const request = indexedDB.open(DB_NAME, DB_VERSION);

		request.onerror = () => reject(request.error);
		request.onsuccess = () => {
			db = request.result;
			resolve(db);
		};

		request.onupgradeneeded = (event) => {
			const database = event.target.result;

			if (!database.objectStoreNames.contains(COLLECTIONS_STORE)) {
				database.createObjectStore(COLLECTIONS_STORE, { keyPath: 'id', autoIncrement: true });
			}

			if (!database.objectStoreNames.contains(WORDS_STORE)) {
				const wordStore = database.createObjectStore(WORDS_STORE, { keyPath: 'id', autoIncrement: true });
				wordStore.createIndex('collection_id', 'collection_id', { unique: false });
			}
		};
	});
}

export async function getLocalCollections() {
	const database = await openDB();
	return new Promise((resolve, reject) => {
		const transaction = database.transaction([COLLECTIONS_STORE, WORDS_STORE], 'readonly');
		const collectionsStore = transaction.objectStore(COLLECTIONS_STORE);
		const wordsStore = transaction.objectStore(WORDS_STORE);

		const collectionsRequest = collectionsStore.getAll();

		collectionsRequest.onsuccess = async () => {
			const collections = collectionsRequest.result;

			const collectionsWithWords = await Promise.all(
				collections.map(async (collection) => {
					const words = await new Promise((res, rej) => {
						const wordIndex = wordsStore.index('collection_id');
						const wordRequest = wordIndex.getAll(collection.id);
						wordRequest.onsuccess = () => res(wordRequest.result);
						wordRequest.onerror = () => rej(wordRequest.error);
					});
					return { ...collection, words };
				})
			);

			resolve(collectionsWithWords);
		};

		collectionsRequest.onerror = () => reject(collectionsRequest.error);
	});
}

export async function addLocalCollection(name) {
	const database = await openDB();
	return new Promise((resolve, reject) => {
		const transaction = database.transaction([COLLECTIONS_STORE], 'readwrite');
		const store = transaction.objectStore(COLLECTIONS_STORE);

		const collection = {
			name,
			created_at: new Date().toISOString()
		};

		const request = store.add(collection);

		request.onsuccess = () => {
			resolve({ ...collection, id: request.result });
		};

		request.onerror = () => reject(request.error);
	});
}

export async function updateLocalCollection(id, name) {
	const database = await openDB();
	return new Promise((resolve, reject) => {
		const transaction = database.transaction([COLLECTIONS_STORE], 'readwrite');
		const store = transaction.objectStore(COLLECTIONS_STORE);

		const getRequest = store.get(id);

		getRequest.onsuccess = () => {
			const collection = getRequest.result;
			if (collection) {
				collection.name = name;
				const updateRequest = store.put(collection);
				updateRequest.onsuccess = () => resolve(collection);
				updateRequest.onerror = () => reject(updateRequest.error);
			} else {
				reject(new Error('Collection not found'));
			}
		};

		getRequest.onerror = () => reject(getRequest.error);
	});
}

export async function deleteLocalCollection(id) {
	const database = await openDB();
	return new Promise((resolve, reject) => {
		const transaction = database.transaction([COLLECTIONS_STORE, WORDS_STORE], 'readwrite');
		const collectionsStore = transaction.objectStore(COLLECTIONS_STORE);
		const wordsStore = transaction.objectStore(WORDS_STORE);

		const wordIndex = wordsStore.index('collection_id');
		const wordRequest = wordIndex.getAll(id);

		wordRequest.onsuccess = () => {
			const words = wordRequest.result;
			words.forEach(word => {
				wordsStore.delete(word.id);
			});

			const deleteRequest = collectionsStore.delete(id);
			deleteRequest.onsuccess = () => resolve();
			deleteRequest.onerror = () => reject(deleteRequest.error);
		};

		wordRequest.onerror = () => reject(wordRequest.error);
	});
}

export async function addLocalWords(collectionId, words) {
	const database = await openDB();
	return new Promise((resolve, reject) => {
		const transaction = database.transaction([WORDS_STORE], 'readwrite');
		const store = transaction.objectStore(WORDS_STORE);

		const addedWords = [];

		words.forEach(word => {
			const wordData = {
				collection_id: collectionId,
				dutch: word.dutch,
				translation: word.translation,
				created_at: new Date().toISOString()
			};

			const request = store.add(wordData);
			request.onsuccess = () => {
				addedWords.push({ ...wordData, id: request.result });
			};
		});

		transaction.oncomplete = () => resolve(addedWords);
		transaction.onerror = () => reject(transaction.error);
	});
}

export async function deleteLocalWords(collectionId) {
	const database = await openDB();
	return new Promise((resolve, reject) => {
		const transaction = database.transaction([WORDS_STORE], 'readwrite');
		const wordsStore = transaction.objectStore(WORDS_STORE);
		const wordIndex = wordsStore.index('collection_id');
		const wordRequest = wordIndex.getAll(collectionId);

		wordRequest.onsuccess = () => {
			const words = wordRequest.result;
			words.forEach(word => {
				wordsStore.delete(word.id);
			});
			resolve();
		};

		wordRequest.onerror = () => reject(wordRequest.error);
	});
}

export async function clearLocalData() {
	const database = await openDB();
	return new Promise((resolve, reject) => {
		const transaction = database.transaction([COLLECTIONS_STORE, WORDS_STORE], 'readwrite');

		const collectionsStore = transaction.objectStore(COLLECTIONS_STORE);
		const wordsStore = transaction.objectStore(WORDS_STORE);

		collectionsStore.clear();
		wordsStore.clear();

		transaction.oncomplete = () => resolve();
		transaction.onerror = () => reject(transaction.error);
	});
}

export async function migrateLocalToSupabase(supabase, userId) {
	const collections = await getLocalCollections();

	const migrationResults = [];

	for (const collection of collections) {
		const { data: newCollection, error: collectionError } = await supabase
			.from('collections')
			.insert([{ name: collection.name, user_id: userId }])
			.select()
			.single();

		if (collectionError) {
			console.error('Error migrating collection:', collectionError);
			continue;
		}

		if (collection.words && collection.words.length > 0) {
			const wordsToInsert = collection.words.map(word => ({
				collection_id: newCollection.id,
				dutch: word.dutch,
				translation: word.translation
			}));

			const { error: wordsError } = await supabase
				.from('words')
				.insert(wordsToInsert);

			if (wordsError) {
				console.error('Error migrating words:', wordsError);
			}
		}

		migrationResults.push(newCollection);
	}

	await clearLocalData();

	return migrationResults;
}
