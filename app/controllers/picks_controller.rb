class PicksController < ApplicationController
	include ActiveStorage::SetCurrent

	before_action :verify_any_user, only: [:create, :update, :week_picks, :create_or_update_pick, :sorted_picks]

	def index
		Rails.logger.debug("PicksController.index")
		@picks = Pick.where(week_id: params[:week_id]).joins(:pool_entry).where('pool_entries.user_id = ?', current_user.id)
		respond_to do | format |
			format.json {render :json => @picks.to_json(include: [{pool_entry: {only: [:id, :team_name] }}, nfl_team: {only: [:id, :name], :methods => [:logo_url_small]}] ) }
		end
	end

	def create_or_update_pick
		Rails.logger.debug("create_or_update_pick")
		safe_params = picks_params
		@week = Week.find(safe_params[:week_id])
		@pool_entry = PoolEntry.find(safe_params[:pool_entry_id])

		if @pool_entry.knocked_out == true
			error_message = "You can't change the pick for a knocked_out pool entry!"
      render :json => {:error => error_message}, :status => :bad_request
    else
			@pick_this_week = Pick.where(pool_entry_id: @pool_entry.id).where(week_id: @week.id).first

			if @pick_this_week.present?
				@pick_this_week.update(safe_params)

				if @pick_this_week.save
					respond_to do | format |
						format.json {render json: @pick_this_week }
					end
				else
					respond_to do | format |
						error_message = ""
						@pick_this_week.errors.each{ |attr,msg| error_message << "#{attr} #{msg} " }
						format.json { render :json => [:error =>  error_message], :status => :internal_server_error}
					end
				end

			else
				@pick = Pick.new

				@pick.update(safe_params)

				if @pick.save
					respond_to do | format |
						format.json { render json: @pick }
					end
				else
					respond_to do | format |
						error_message = ""
						@pick.errors.each{ |attr,msg| error_message << "#{attr} #{msg} " }
						format.json { render :json => [:error =>  error_message], :status => :internal_server_error}
					end
				end
			end
		end
	end

	def create
		Rails.logger.debug("Picks.create")
		@pick = Pick.new

		@pick.update(picks_params)

		if @pick.save
			respond_to do | format |
				format.json { render json: @pick }
			end
		else
			respond_to do | format |
				error_message = ""
				@pick.errors.each do |error|
					error_message += "#{error.attribute.to_s} #{error.message} "
				end
				format.json { render :json => [:error =>  error_message], :status => :internal_server_error}
			end
		end
	end

	def update
		Rails.logger.debug("Picks.update")
		@pool_entry = PoolEntry.find(params[:pool_entry_id])
		@pick = Pick.where(week_id: params[:week_id], pool_entry_id: params[:pool_entry_id]).first unless current_user.id != @pool_entry.user_id

		@pick.update(picks_params)

		if @pick.save
			respond_to do | format |
				format.json {render json: @pick }
			end
		else
			respond_to do | format |
				error_message = ""
				@pick.errors.each do |error|
					error_message += "#{error.attribute.to_s} #{error.message} "
				end
				format.json { render :json => [:error =>  error_message], :status => :internal_server_error}
			end
		end
	end

	def week_picks
		@week = Week.find(params[:week_id])
		@this_weeks_picks = Pick.where(week_id: params[:week_id])

		if @week.open_for_picks == true
			Rails.logger.error("ERROR you can't view the picks for a week before it is closed!")
			error_message = "You cannot view the picks for this week until the games start!"
			render :json => [:error => error_message], :status => :bad_request
		else
			respond_to do |format|
				format.json { render :json => @this_weeks_picks.to_json(include: [nfl_team: {only: [:id, :name], :methods => [:logo_url_small]}])}
			end
		end
	end

	def sorted_picks
		@week = Week.find(params[:week_id])

		if @week.open_for_picks?
			@season = @week.season
			locked_matchups = Matchup.where(week_id: @week.id, locked: true)
			@locked_picks = Pick.includes(:pool_entry).where(pool_entries: { season_id: @season.id }).where(matchup_id: locked_matchups.pluck(:id))

			if @locked_picks.present?
				@picks_per_team_hash = {}

				@locked_picks.each do |pick|
					team_name = pick.nfl_team.name
					@picks_per_team_hash[team_name] ||= 0
					@picks_per_team_hash[team_name] += 1
				end

				@sorted_picks = @picks_per_team_hash.sort_by { |_k, v| -v }

				@formatted_data = @sorted_picks.map { |team_name, count| [team_name, count] }

				respond_to do |format|
					format.json { render json: @formatted_data }
				end
			else
				error_message = "You cannot view the sorted picks for this week until the games start!"
				render json: { error: error_message }, status: :bad_request
			end
		else
			@this_weeks_picks = Pick.where(week_id: params[:week_id])
			@picks_per_team_hash = {}

			@this_weeks_picks.each do |pick|
				team_name = pick.nfl_team.name
				@picks_per_team_hash[team_name] ||= 0
				@picks_per_team_hash[team_name] += 1
			end

			@sorted_picks = @picks_per_team_hash.sort_by { |_k, v| -v }

			@formatted_data = @sorted_picks.map { |team_name, count| [team_name, count] }

			respond_to do |format|
				format.json { render json: @formatted_data }
			end
		end
	end

	private

	def picks_params
		params.permit(:pool_entry_id, :week_id, :team_id, :locked_in, :auto_picked, :matchup_id)
	end


end