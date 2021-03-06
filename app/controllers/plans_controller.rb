class PlansController < ApplicationController
  before_action :logged_in_user, only: [:create, :edit, :update, :new, :clone, :destroy]

  def index
    if params[:q]
      @q = Plan.ransack(params[:q])
      params[:p] = params[:q].deep_dup
      params[:p].delete(:user_name_or_title_or_destinations_description_or_destinations_name_or_prefectures_cont)
      params[:p][:title_or_destinations_description_or_destinations_name_or_prefectures_cont] = \
        params[:q][:user_name_or_title_or_destinations_description_or_destinations_name_or_prefectures_cont]
      @plans = @q.result(distinct: true).paginate(page: params[:page])
      @anonymous_q = AnonymousUserPlan.ransack(params[:p])
      @anonymousUserPlans = @anonymous_q.result(distinct: true)
    else
      @q = Plan.ransack(params[:q])
      @plans = Plan.where(published: true).paginate(page: params[:page])
      @anonymousUserPlans = AnonymousUserPlan.all
    end
  end

  def update
    @plan = Plan.find(params[:id])
    if @plan.update_attributes(plan_params)
      flash[:success] = "プランが更新されました"
      redirect_to edit_plan_url
    else
      flash[:danger] = "タイトルを入力してください"
      redirect_to edit_plan_url
    end
  end

  def edit
    @plan = Plan.find(params[:id])
    gon.planData = @plan.destinations.map{|d| d.name}
    count = 10 - @plan.destinations.count
    count.times { @plan.destinations.build }
  end

  def show
    @plan = Plan.find(params[:id])
    @destinations = @plan.destinations
    gon.planData = @destinations.map{|d| d.name}
  end

  def create
    @plan = current_user.plans.build(plan_params)
    if @plan.save
      redirect_to controller: 'plans', action: 'show', id: @plan.id
    else
      flash[:danger] = "タイトルを入力してください"
      redirect_to acition: 'new'
    end
  end

  def new
    @plan = Plan.new
    10.times { @plan.destinations.build }
  end

  def clone
    if params[:is_anonymous]
      p = AnonymousUserPlan.find(params[:id]).amoeba_dup
      @plan = Plan.new(title:p.title, destinations: p.destinations)
      gon.planData = @plan.destinations.map{|d| d.name}
      count = 10 - @plan.destinations.count
      count.times { @plan.destinations.build }
    else
      @old_plan = Plan.find(params[:id])
      if current_user?(@old_plan.user)
        redirect_to edit_plan_url(@old_plan), flash:{id: @old_plan.id}
        flash.discard(:id)
      else
        p = Plan.find(params[:id]).amoeba_dup
        @plan = Plan.new(title:p.title, destinations: p.destinations)
        gon.planData = @plan.destinations.map{|d| d.name}
        count = 10 - @plan.destinations.count
        count.times { @plan.destinations.build }
      end
    end
  end

  def destroy
    @plan = Plan.find(params[:id])
    @user = @plan.user
    if current_user?(@user)
      @plan.destroy
      flash[:success] = "プランを削除しました"
      redirect_to @user
    end
  end

  private
    def plan_params
      params.require(:plan).permit(
        :title,
        :picture,
        :user_id,
        :published,
        :prefectures,
        destinations_attributes: [:id, :time, :name, :_destroy, :picture, :description]
      )
    end

    def search_params
      params.require(:q).permit(:title_or_destinations_description_or_destinations_name_cont)
    end
end
