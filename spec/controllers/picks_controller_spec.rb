require 'spec_helper'

describe PicksController do

  pending "should gracefully trap if user attempts to change after locked_in"

  describe "GET index" do
  	it "sets @picks to the user's picks from this season"
  	it "does not include another user's picks in @picks"
  	it "does not include picks from a different season in @picks"
  end

  describe "GET new" do
  	# Do we need this? I am envisioning a "matchup" page where you can
  	# click "Choose Team" button for either team
  	it "sets @pick to a new pick"
  end

  describe "POST create" do

  	context "with a valid pool entry"

	  	context "with valid input" do
	  		it "redirects to the My Picks page"
	  		it "saves the pick"
	  		it "sets the flash success message"
	  	end


	  	context "with invalid input" do # i.e. after deadline (should I create separate tests?)
	  		it "does not create a new pick"

	  		# A previously saved pick is not overwritten if you try to change after the deadline
	  		it "does not invalidate an already saved pick" 
	  		it "redirects to the matchup page"
	  		it "sets a flash danger message"
	  	end

	  end

	  context "with an invalid pool entry" do
	  	it "does not save the pick for a knocked out pool entry"
	  	it "does not save the pick for an unpaid pool entry"
	  end
  end

  describe "GET missing_picks" do
  	# Will we want this in pool_entries_controller since we'll search
  	# for pool_entries without a pick for that week?
  	it "sets @missing_picks to the missing picks from the current week"
  	it "does not include picks from a later week in @missing_picks"
  	it "does not include completed picks in @missing_picks"
  end

end