# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_taurus_session',
  :secret      => '1433b90881215f9e063a6097bbe565cb5308ae12ce101ac9cb992328f1a301190e81cc7049c08126170a572cfbd3923bd9de100df0d47c1ae2da1e485d5b06dc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
