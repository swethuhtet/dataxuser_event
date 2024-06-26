class EventsController < ApplicationController  
  #GET ALL
  def index
    @events = Event.all
  end

  #SHOW
  def show
    @event = Event.find(params[:id])
  end
  
  #NEW
  def new
    @event = Event.new
    @users = User.all
  end

  #EDIT
  def edit
    @event = Event.find(params[:id])
    @users = User.all
    @users_ids = @event.event_details.pluck(:user_id) 
    @selected_users = User.where(id: @users_ids)
  end

  #CREATE
  def create
    respond_to do |format|
      begin
        @user_ids = params[:user_ids].map(&:to_i).reject(&:zero?)
  
        event = Events::EventUsecase.new(event_params) 
        response = event.create(@user_ids) 
        if response[:status] == :created
          format.html { redirect_to events_path(event), notice: t('messages.common.create_success', data: "Event") }
          format.json { render :show, status: :created, location: event }
        else
          @event = response[:event]
          @users = User.all
          flash[:errors] = response[:errors]
          format.html { render :new, status: :unprocessable_entity}
          format.json { render json: {errors: response[:errors]}, status: :unprocessable_entity }
        end
      rescue StandardError => e
        logger.error "There is something wrong with creating event. #{e.message}"
        format.html { render file: "#{Rails.root}/public/500.html", layout: true, status: :internal_server_error }
      end
    end
  end

  #UPDATE
  def update
    respond_to do |format|
      begin
        updated_event = Event.find(params[:id])
        @event = Events::EventUsecase.new(event_params)
        @user_ids = params[:user_ids].map(&:to_i).reject(&:zero?)
        response = @event.update(updated_event,@user_ids)
  
        if response[:status] == :updated
          format.html { redirect_to events_path, notice: t('messages.common.update_success', data: "Event") }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: {errors: response[:errors]}, status: :unprocessable_entity }
        end
      rescue ActiveRecord::RecordNotFound => e
        format.html { render file: "#{Rails.root}/public/404.html", layout: true, status: :not_found }
        format.json { render json: { error: "Event not found" }, status: :not_found }
      rescue StandardError => e
        logger.error "There is something wrong with updating event. #{e.message}"
        format.html { render file: "#{Rails.root}/public/500.html", layout: true, status: :internal_server_error }
      end   
    end
  end

  #DELETE
  def destroy 
    @event = Event.find(params[:id])
    @deleted_event = Events::EventUsecase.new(nil)

    respond_to do |format|
      begin
        if @deleted_event.destroy(@event)
          format.html { redirect_to events_path, notice: t('messages.common.destroy_success', data: "Event") }
          format.json { head :no_content }
        end
      rescue ActiveRecord::RecordNotFound => e
        format.html { render file: "#{Rails.root}/public/404.html", layout: true, status: :not_found }
        format.json { render json: { error: 'Event not found' }, status: :not_found }
      rescue StandardError => e
        logger.error "There is something wrong with updating event. #{e.message}"
        format.html { render file: "#{Rails.root}/public/500.html", layout: true, status: :internal_server_error }
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :start_date, :start_time, :end_date, :end_time, :description)
  end

end
