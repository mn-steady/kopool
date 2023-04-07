class GenerateAuthTokensForExistingUsers < ActiveRecord::Migration[7.0]
  def up
  	User.all.each do |user|
  		user.ensure_authentication_token
  		user.save
  	end
  end

  def down
  	raise ActiveRecord::IrreversibleMigration
  end
end
