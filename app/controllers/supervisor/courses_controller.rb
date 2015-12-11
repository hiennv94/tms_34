class Supervisor::CoursesController < Supervisor::BaseController
  before_action :load_course, except: [:index, :new, :create]
  before_action :verify_supervisor, only: [:edit, :update]
  before_action :verify_owner, only: [:destroy]

  def index
    @courses = Course.all.paginate page: params[:page]
  end

  def new
    @course = Course.new
    @subjects = Subject.all
    @subjects.each do |subject|
      @course.course_subjects.build subject_id: subject.id
    end
  end

  def create
    @course = Course.new course_params
    if @course.save
      flash[:success] = t "flash.create_course"
      redirect_to supervisor_root_url
    else
      @subjects = Subject.all
      @subjects.each do |subject|
        @course.course_subjects.build subject_id: subject.id
      end
      render :new
    end
  end

  def edit
    @subjects = Subject.all
    (Subject.all - @course.subjects).each do |subject|
      @course.course_subjects.build subject: subject
    end
  end

  def update
    if @course.update_attributes course_params
      flash[:success] = t "flash.subject_update_success"
      redirect_to supervisor_root_url
    else
      flash[:danger] = t "flash.subject_update_failed"
      render :edit
    end
  end

  def destroy
    if @course.destroy
      flash[:success] = t "flash.destroy_ok"
      redirect_to supervisor_root_url
    else
      flash[:danger] = t "flash.destroy_failed"
      redirect_to supervisor_root_url
    end
  end

  private
  def course_params
    params.require(:course).permit :name, :description, :start_date, :end_date,
      :status, :create_by, course_subjects_attributes:[:id, :course_id, :subject_id, :_destroy]
  end

  def load_course
    @course = Course.find params[:id]
  end

  def verify_supervisor
    unless @course.users.include? current_user
      flash[:danger] = t "flash.only_supervisor"
      redirect_to :back
    end
  end

  def verify_owner
    @user = User.find_by_id @course.create_by
    if @user != current_user
      flash[:danger] =  t "flash.owner"
      redirect_to supervisor_root_url
    end
  end
end
