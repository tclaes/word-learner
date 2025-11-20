<svelte:head>
	<title>About</title>
	<meta name="description" content="About VocabMaster - A Revolutionary Language Learning Platform" />
</svelte:head>

<div class="text-column">
	<h1>About VocabMaster</h1>

	<section class="hero-section">
		<p class="tagline">
			Empowering the next generation of multilingual learners, one word at a time.
		</p>
	</section>

	<section class="story-section">
		<h2>The Story Behind This App</h2>
		<p>
			VocabMaster was born out of a father's love and dedication to his son's education.
			As my son embarked on his journey to learn Dutch, I witnessed firsthand the challenges
			young learners face when trying to master a new language. Traditional methods felt
			outdated and uninspiring, so I set out to create something different.
		</p>
		<p>
			This app represents countless hours of careful design and development, all driven by
			one simple goal: to make language learning not just effective, but genuinely engaging
			and fun for young minds.
		</p>
	</section>

	<section class="features-section">
		<h2>Why VocabMaster Changes Everything</h2>
		<div class="features-grid">
			<div class="feature-card">
				<div class="feature-icon">🎯</div>
				<h3>Adaptive Learning</h3>
				<p>
					Our intelligent quiz system adapts to your learning pace, ensuring optimal
					retention without overwhelming the learner. Each session is carefully timed
					to maximize focus and minimize fatigue.
				</p>
			</div>
			<div class="feature-card">
				<div class="feature-icon">📊</div>
				<h3>Progress Tracking</h3>
				<p>
					Comprehensive analytics provide deep insights into learning patterns. Parents
					and students can track accuracy, identify weak areas, and celebrate achievements
					together.
				</p>
			</div>
			<div class="feature-card">
				<div class="feature-icon">🎮</div>
				<h3>Gamified Experience</h3>
				<p>
					Learning should never feel like a chore. Our gamified approach transforms
					vocabulary practice into an exciting challenge that keeps learners coming
					back for more.
				</p>
			</div>
			<div class="feature-card">
				<div class="feature-icon">🔄</div>
				<h3>Bidirectional Learning</h3>
				<p>
					Master both translation directions effortlessly. Whether going from Dutch to
					English or vice versa, our flexible quiz system ensures complete linguistic
					competency.
				</p>
			</div>
			<div class="feature-card">
				<div class="feature-icon">📚</div>
				<h3>Custom Collections</h3>
				<p>
					Organize vocabulary by themes, difficulty levels, or school curriculum.
					This personalized approach ensures that learning stays relevant and focused
					on what matters most.
				</p>
			</div>
			<div class="feature-card">
				<div class="feature-icon">⏱️</div>
				<h3>Optimized Sessions</h3>
				<p>
					Research-backed 5-minute quiz sessions maintain peak concentration levels.
					Short, frequent practice sessions have been proven to dramatically improve
					long-term retention.
				</p>
			</div>
		</div>
	</section>

	<section class="impact-section">
		<h2>The Science of Language Acquisition</h2>
		<p>
			VocabMaster is built on proven pedagogical principles that accelerate language learning:
		</p>
		<ul class="benefits-list">
			<li>
				<strong>Spaced Repetition:</strong> Our system naturally encourages repeated exposure
				to vocabulary, reinforcing neural pathways and ensuring words move from short-term to
				long-term memory.
			</li>
			<li>
				<strong>Active Recall:</strong> By requiring learners to actively retrieve information
				rather than passively review it, we strengthen memory formation and improve retention
				by up to 400%.
			</li>
			<li>
				<strong>Immediate Feedback:</strong> Instant correction helps learners identify and
				fix mistakes before they become ingrained, accelerating the path to fluency.
			</li>
			<li>
				<strong>Progress Visualization:</strong> Seeing tangible progress releases dopamine,
				creating positive associations with learning and building intrinsic motivation.
			</li>
			<li>
				<strong>Contextual Organization:</strong> Grouping words by theme creates mental
				frameworks that make vocabulary easier to remember and apply in real-world situations.
			</li>
		</ul>
	</section>

	<section class="testimonial-section">
		<h2>A Parent's Pride</h2>
		<blockquote class="testimonial">
			<p>
				Watching my son's confidence grow as he masters Dutch has been one of the most
				rewarding experiences of my life. What started as a simple tool has become an
				integral part of his daily learning routine. His vocabulary has expanded dramatically,
				and more importantly, he actually looks forward to practice time.
			</p>
			<p>
				Language learning is no longer a struggle—it's become an adventure. That's the
				power of the right tools combined with the right motivation.
			</p>
		</blockquote>
	</section>

	<section class="mission-section">
		<h2>Our Mission</h2>
		<p>
			VocabMaster exists to prove that technology, when thoughtfully designed with love
			and purpose, can transform education. We believe that every child deserves access
			to tools that make learning not just possible, but genuinely enjoyable.
		</p>
		<p>
			This is more than an app—it's a bridge between cultures, a gateway to new opportunities,
			and a testament to what can be achieved when a parent's dedication meets modern technology.
		</p>
		<p class="closing">
			Here's to every learner brave enough to embark on the journey of mastering a new language.
			May VocabMaster be your trusted companion every step of the way.
		</p>
	</section>
</div>

<style>
	.text-column {
		padding: 2rem;
		max-width: 900px;
		margin: 0 auto;
	}

	h1 {
		font-size: 2.5rem;
		color: #1a202c;
		margin-bottom: 1rem;
		text-align: center;
	}

	h2 {
		font-size: 1.875rem;
		color: #2d3748;
		margin-top: 3rem;
		margin-bottom: 1.5rem;
	}

	h3 {
		font-size: 1.25rem;
		color: #2d3748;
		margin-bottom: 0.75rem;
	}

	p {
		line-height: 1.8;
		color: #4a5568;
		margin-bottom: 1.25rem;
		font-size: 1.05rem;
	}

	.hero-section {
		text-align: center;
		padding: 2rem 0 3rem 0;
		border-bottom: 2px solid #e2e8f0;
		margin-bottom: 2rem;
	}

	.tagline {
		font-size: 1.5rem;
		color: #2563eb;
		font-weight: 600;
		font-style: italic;
		margin: 0;
	}

	.story-section {
		background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);
		padding: 2rem;
		border-radius: 12px;
		margin: 2rem 0;
	}

	.features-section {
		margin: 3rem 0;
	}

	.features-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
		gap: 2rem;
		margin-top: 2rem;
	}

	.feature-card {
		background: white;
		border: 2px solid #e2e8f0;
		border-radius: 12px;
		padding: 2rem;
		transition: all 0.3s;
	}

	.feature-card:hover {
		transform: translateY(-4px);
		box-shadow: 0 12px 24px rgba(37, 99, 235, 0.15);
		border-color: #2563eb;
	}

	.feature-icon {
		font-size: 3rem;
		margin-bottom: 1rem;
		text-align: center;
	}

	.feature-card h3 {
		text-align: center;
		color: #2563eb;
		margin-bottom: 1rem;
	}

	.feature-card p {
		font-size: 0.95rem;
		color: #718096;
		line-height: 1.6;
		margin: 0;
	}

	.impact-section {
		background: linear-gradient(135deg, #ebf8ff 0%, #e0f2fe 100%);
		padding: 2rem;
		border-radius: 12px;
		margin: 3rem 0;
	}

	.benefits-list {
		list-style: none;
		padding: 0;
		margin: 2rem 0;
	}

	.benefits-list li {
		background: white;
		padding: 1.5rem;
		margin-bottom: 1rem;
		border-radius: 8px;
		border-left: 4px solid #2563eb;
		box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
		line-height: 1.7;
		color: #4a5568;
	}

	.benefits-list strong {
		color: #2563eb;
		font-weight: 600;
	}

	.testimonial-section {
		margin: 3rem 0;
	}

	.testimonial {
		background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
		padding: 2rem;
		border-radius: 12px;
		border-left: 6px solid #f59e0b;
		font-style: italic;
		margin: 2rem 0;
	}

	.testimonial p {
		color: #78350f;
		font-size: 1.1rem;
		line-height: 1.8;
	}

	.mission-section {
		background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
		padding: 2rem;
		border-radius: 12px;
		margin: 3rem 0 2rem 0;
	}

	.closing {
		font-size: 1.15rem;
		font-weight: 500;
		color: #059669;
		text-align: center;
		margin-top: 2rem;
		padding-top: 2rem;
		border-top: 2px solid #a7f3d0;
	}

	@media (max-width: 768px) {
		h1 {
			font-size: 2rem;
		}

		h2 {
			font-size: 1.5rem;
		}

		.tagline {
			font-size: 1.25rem;
		}

		.features-grid {
			grid-template-columns: 1fr;
		}
	}
</style>
