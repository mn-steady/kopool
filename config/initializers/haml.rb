Rails.application.config.assets.configure do |env|
  env.register_engine '.haml', Tilt::HamlTemplate
end
