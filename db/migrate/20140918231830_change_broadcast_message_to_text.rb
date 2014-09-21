class ChangeBroadcastMessageToText < ActiveRecord::Migration
  def up
    change_column :web_states, :broadcast_message, :text
	end

	def down
	  change_column :web_states, :broadcast_message, :string
	end
end
