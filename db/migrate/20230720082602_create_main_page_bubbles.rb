class CreateMainPageBubbles < ActiveRecord::Migration[7.0]
  def change
    create_table :main_page_bubbles do |t|

      t.timestamps
    end
  end
end
