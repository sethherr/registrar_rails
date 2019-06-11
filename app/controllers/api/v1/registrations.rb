# frozen_string_literal: true

class API::V1::Registrations < API::Base
  resource :registrations do
    helpers do
      def current_registration
        @current_registration ||= current_user.registrations.find(params[:registration_id] || params[:id])
      end

      def registrations
        @page = params[:page] || 1
        @per_page = params[:per_page] || 50
        @paginated_obj = current_user.registrations.order(id: :desc).page(@page).per(@per_page)
        ActiveModel::ArraySerializer.new(@paginated_obj,
                                         each_serializer: RegistrationSerializer,
                                         root: false).as_json
      end

      def registration_logs
        @page = params[:page] || 1
        @per_page = params[:per_page] || 50
        @paginated_obj = registration_logs.order(id: :desc).page(@page).per(@per_page)
        ActiveModel::ArraySerializer.new(@paginated_obj,
                                         each_serializer: RegistrationLogSerializer,
                                         root: false).as_json
      end
    end

    desc "Current User's registrations"
    params do
      optional :page, type: Integer, desc: "page for pagination"
    end
    get "/" do
      {
        registrations: registrations,
        links: paginate("registrations"),
      }
    end

    desc "Record Register for Current User"
    params do
      requires :status, type: String, values: Registration.statuses, desc: "status"
      optional :title, type: String, desc: "title"
      optional :description, type: String, desc: "description"
      optional :main_category, type: String, desc: "main category"
      optional :manufacturer, type: String, desc: "manufacturer"
      optional :tags_list, type: String, desc: "list of tags, separated by commas"
    end
    post "/" do
      registration = Registration.new(status: params[:status], title: params[:title], description: params[:description],
                                      main_category_tag: params[:main_category], manufacturer_tag: params[:manufacturer],
                                      tags_list: params[:tags_list])
      if registration.save
        Ownership.create_for(registration, creator: current_user, owner: current_user)
        registration.reload
        RegistrationSerializer.new(registration, root: "registration").as_json
      else
        error!({ error: registration.errors.full_messages.to_sentence }, 400)
      end
    end

    desc "registrations logs"
    params do
      requires :registration_id, type: String
    end
    get "/:registration_id/logs" do
      {
        registrations: registrations,
        links: paginate("registration_logs"),
      }
    end
  end
end
