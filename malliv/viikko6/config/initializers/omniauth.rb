OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '473617039428118', '6fa39a4ae98725125a9ca5bd07989fc6'
end