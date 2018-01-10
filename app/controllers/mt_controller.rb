class MtController < ApplicationController
  unloadable
 
  before_filter :find_project_by_project_id, :authorize, :get_trackers
  menu_item :traceability_matrix
  
  helper :issues
  helper :projects
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

  attr_accessor :issue_rows
  attr_accessor :issue_cols 
  attr_accessor :query_rows
  attr_accessor :query_cols
  attr_accessor :tracker_rows
  attr_accessor :tracker_cols
  attr_accessor :issue_pairs
  attr_accessor :not_seen_issue_cols


  def init_macro_context(project)
    @project = project
  end
  
  def build_list_of_issues 
    @issue_rows = @query_rows.issues().sort {|issue_a, issue_b| issue_a.id <=> issue_b.id}
    @issue_cols = @query_cols.issues().sort {|issue_a, issue_b| issue_a.id <=> issue_b.id}
    @issue_pairs = {}
    @not_seen_issue_cols = {}
    
    if @issue_rows.empty?
      return
    end
    
    if @issue_cols.empty?
      return
    end

    relations = IssueRelation.where("issue_from_id IN (:ids) OR issue_to_id IN (:ids)", :ids => @issue_rows.map(&:id)).all

    Issue.load_relations(@issue_cols)

    @not_seen_issue_cols = @issue_cols.dup
    relations.each do |relation|
      if @not_seen_issue_cols.include?relation.issue_to
        @issue_pairs[relation.issue_from] ||= {}
        @issue_pairs[relation.issue_from][relation.issue_to] ||= []
        @issue_pairs[relation.issue_from][relation.issue_to] << true
        @not_seen_issue_cols.delete relation.issue_to
      elsif @not_seen_issue_cols.include?relation.issue_from
        @issue_pairs[relation.issue_to] ||= {}
        @issue_pairs[relation.issue_to][relation.issue_from] ||= []
        @issue_pairs[relation.issue_to][relation.issue_from] << true
        @not_seen_issue_cols.delete relation.issue_from
      else
      end
    end

    relations = IssueRelation.where("issue_from_id IN (:ids) OR issue_to_id IN (:ids)", :ids => @issue_cols.map(&:id)).all

    issue_rows_copy = @issue_rows.dup
    relations.each do |relation|
      if issue_rows_copy.include?relation.issue_from
        @issue_pairs[relation.issue_from] ||= {}
        @issue_pairs[relation.issue_from][relation.issue_to] ||= []
        @issue_pairs[relation.issue_from][relation.issue_to] << true
        issue_rows_copy.delete relation.issue_to
      elsif issue_rows_copy.include?relation.issue_to
        @issue_pairs[relation.issue_to] ||= {}
        @issue_pairs[relation.issue_to][relation.issue_from] ||= []
        @issue_pairs[relation.issue_to][relation.issue_from] << true
        issue_rows_copy.delete relation.issue_from
      else
      end
    end

    return 
    
  end
  
  def get_trackers(query_rows_id=Setting.plugin_traceability_matrix['tracker0'],
                   query_cols_id=Setting.plugin_traceability_matrix['tracker1'])
    @tracker_rows = nil
    @query_rows = IssueQuery.find_by_id(query_rows_id)
    if @project.nil?
      @query_rows.project = Project.find_by_id(@query_rows.project_id)
    else
      @query_rows.project = @project
    end
    @query_rows.filters.each do |name, options|
      if (name == "tracker_id")
        tracker_id = options[:values].first
         @tracker_rows = Tracker.find_by_id(tracker_id)
      end
    end

    # Grouped by category cause an error when getting the issues from the query
    if (@query_rows.group_by="category")
      @query_rows.group_by=""
    end

    @tracker_cols = nil
    @query_cols = IssueQuery.find_by_id(query_cols_id)
    if @project.nil?
      @query_cols.project = Project.find_by_id(@query_cols.project_id)
    else
      @query_cols.project = @project
    end
    @query_cols.filters.each do |name, options|
      if (name == "tracker_id")
        tracker_id_ = options[:values].first
         @tracker_cols = Tracker.find_by_id(tracker_id_)
      end
    end

    # Grouped by category cause an error when getting the issues from the query
    if (@query_cols.group_by="category")
      @query_cols.group_by=""
    end

  rescue ActiveRecord::RecordNotFound
    flash[:error] = l(:'traceability_matrix.setup')
    render
  end
end


