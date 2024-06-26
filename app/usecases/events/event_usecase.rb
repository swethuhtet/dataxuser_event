require_relative '../../forms/events/event_form.rb'
module Events
  class EventUsecase < BaseUsecase
    def initialize(params)
      @params = params
      @form = Events::EventForm.new(params)
    end
    
    #CREATE
    def create(user_ids)
      begin
        event_create_service = Events::EventService.new(@form.attributes) 
        if @form.valid?
          response = event_create_service.create(user_ids)
          if response[:status] == :created 
            return {event: response[:event], status: :created}
          end
        else
          @event = Event.new(@form.attributes.except(:start_time, :end_time))
          return {event: @event, errors: @form.errors, notice:"Create Event error",status: :unprocessable_entity}
        end
      rescue StandardError => errors
        return {event: @event, errors: errors.message, status: :unprocessable_entity}
      end    
    end

    #UPDATE
    def update(updated_event,user_ids)
      begin
        if @form.valid?
          event_update_service = Events::EventService.new(@params)
          response = event_update_service.update(updated_event,user_ids)
          if response[:status] == :updated
            return {event: response[:event], status: :updated}
          end
        else
          @event = Event.new(@form.attributes.except(:start_time,:end_time))
          return {event: @event, errors: @form.errors, status: :unprocessable_entity}
        end
      rescue StandardError => errors
        return {event: @event, errors: errors.message, status: :unprocessable_entity}
      end
    end

    #DELETE
    def destroy(deleted_event)
      begin
        event_delete_service = Events::EventService.new(@params)
        if event_delete_service.destroy(deleted_event)
          return true
        else
          return false
        end
      rescue StandardError => errors
        return {errors: errors.message}
      end
    end

  end
end
