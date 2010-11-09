# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rp2_session',
  :secret      => '948f1bd94a44b2a2c24fa55fd5866d51cf3cfa0f9a9a639c1bce597534f2e12fc112dc57c4c84312720aadae978f9d37006a233ade18d765ec551429557fb6be'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
