class ChangeBroadcastMessageToText < ActiveRecord::Migration[7.0]
  def up
    change_column :web_states, :broadcast_message, :text
	end

	def down
	  change_column :web_states, :broadcast_message, :string
	end
end
