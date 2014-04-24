require 'spec_helper'

describe PoolEntriesController do
	describe "GET new" do

		context "without logged in user" do
				it "redirects to the new user session path"
				it "sets the flash notice message"
		end

		context "with open registration" do
			it "sets @pool_entry to a new pool entry"
		end

		context "with closed registration" do 
			it "does not set @pool_entry to a new pool entry"
			it "sets flash danger message"
		end
	end

	describe "POST create" do
		context "with valid input" do
			it "saves the new pool entry"
			it "associates the new pool entry with the signed in user"
			it "redirects to the My Picks page"
			it "sets the flash success message"
		end

		context "with invalid input" do
			it "does not save the pool entry"
			it "renders the :new template"
			it "sets the flash danger message"
		end
	end
end