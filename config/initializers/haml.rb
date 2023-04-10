Rails.application.config.assets.configure do |env|
  env.register_transformer 'text/haml', 'text/html', Tilt::HamlTemplate
end
