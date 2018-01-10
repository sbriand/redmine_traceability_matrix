require 'redmine'
require 'application_helper'

module TraceabilityMatrixMacros
  
  ##############################################################################
  
  Redmine::WikiFormatting::Macros.register do
    error_message_m1 = "Traceability matrix between two list of issues, as a simple cross reference table.\n\n" +
         "+Syntax:+\n" +
         "<pre>{{traceability_matrix_short(issue_query_id_row,issue_query_id_col,[options])}}</pre>\n\n" +
         "+Parameters+\n" +
         "* _issue_query_id_row_ : id of the issue query to get the list of issues to rows \n" +
         "* _issue_query_id_col_ : id of the issue query to get the list of issues to cols \n\n" +
         "+Options:+\n" +
         "* -p = project_id : Restrict explicitly to project. The parameter project_id can be either id number or name.\n" +
         "* -w = number : Specifies the width of the tables, in number of columns. The traceability matrix may be split into several tables.\n" +
         "* -i : Displays the ID of issues in both columns.\n" +
         "* -t : Displays the text subject of issue in columns and rows.\n" +
         "* -tc : Displays the text subject of issue in columns.\n" +
         "* -tr : Displays the text subject of issue in rows.\n" +
         "* -d : Displays the text description of issue in row.\n" +
         "* cf_xx : Display the custom field with number xx.\n" +
         "* -ir : Displays the ID of issues in rows 1.\n" +
         "* -ic : Displays the ID of issues in columns.\n" +
         "* -s : Displays the status of issues in rows and columns.\n" +
         "* -sr : Displays the status of issues in rows.\n" +
         "* -sc : Displays the status of issues in columns.\n\n" +
         "+Examples:+\n" +
         "<pre>{{traceability_matrix_short(1,2)}} ->  Show the matrix using issue queries with id 1 and 2\n" +
         "{{traceability_matrix_short(20,144,-w=20)}} Show the matrix, split into tables that contains 20 columns\n" +
         "{{traceability_matrix_short(20,144,-s)}} Each issue, in rows and columns displays its status\n</pre>\n"

    desc error_message_m1

    macro :traceability_matrix_short do |obj, args|
    
      ## Gestion des arguments ##      
      if args.empty?
        return textilizable(error_message_m1)
      else
        if Query.find_by_id(args[0].strip) == nil
          return 'Error : Unknown query id for rows'
        else
          query_row_id = Query.find(args[0].strip)     
        end
        if Query.find_by_id(args[1].strip) == nil
          return 'Error : Unknown query id for columns'
        else
          query_col_id = Query.find(args[1].strip) 
        end
      end
      
      # default values
      split_nb_cols = 20
      show_subject_row = false;
      show_subject_col = false;
      option_display_description = false;
      
      option_display_status_row = false
      option_display_status_col = false
      option_display_id_row = false
      option_display_id_col = false
      custom_field_id = 0
      project = nil
      
      args[2..-1].each do |arg|
        case arg
        when /^-d/
          # display description of issues
          option_display_description = true
        when /^-w/
          # width of array, in number of columns
          split_nb_cols = arg.delete('-w=').strip
          puts "nb columns param = " + split_nb_cols
        when /-sr/
          # display status of issues
          option_display_status_row = true
          option_display_status_col = false
        when /-sc/
          # display status of issues
          option_display_status_row = false
          option_display_status_col = true
        when /-s/
          # display status of issues
          option_display_status_row = true
          option_display_status_col = true
        when /-ir/
          # display status of issues
          option_display_id_row = true
          option_display_id_col = false
        when /-ic/
          # display status of issues
          option_display_id_row = false
          option_display_id_col = true
        when /-i/
          # display status of issues
          option_display_id_row = true
          option_display_id_col = true
        when /^-tr/
          # show subject text of issues
          show_subject_row = true
          show_subject_col = false
        when /^-tc/
          # show subject text of issues
          show_subject_row = false
          show_subject_col = true
        when /^-t/
          # show subject text of issues
          show_subject_row = true
          show_subject_col = true
        when /^-p/
          project = Project.find(arg[3..arg.length-1])
        when /^cf_/
          custom_field_id = arg[3..arg.length-1].to_i
        else
          puts "sinon" + arg
        end
      end

      ## Execution du controlleur ##
      mt_ctrl = MtController.new
      
      mt_ctrl.init_macro_context(project)
      mt_ctrl.get_trackers(query_row_id, query_col_id)  
      mt_ctrl.build_list_of_issues
            
      disp = String.new
      disp << render(:partial => 'mt/mt_synthese',
                     :locals => {:issue_cols => mt_ctrl.issue_cols, :query_cols => mt_ctrl.query_cols,
                     :issue_rows => mt_ctrl.issue_rows, :query_rows => mt_ctrl.query_rows, :issue_pairs => mt_ctrl.issue_pairs,
                     :not_seen_issue_cols => mt_ctrl.not_seen_issue_cols, :split_nb_cols => split_nb_cols.to_i,
                     :show_subject_row => show_subject_row,
                     :show_subject_col => show_subject_col,
	            	     :option_display_description => option_display_description,
                     :option_display_id_row => option_display_id_row,
                     :option_display_id_col => option_display_id_col,
                     :option_display_status_row => option_display_status_row,
                     :option_display_status_col => option_display_status_col,
                     :custom_field_id => custom_field_id})
      
      return disp.html_safe

    end # Fin macro


    error_message_m2 = "Detailed traceability matrix between two list of issues.\n\n" +
         "+Syntax:+\n" +
         "<pre>{{traceability_matrix_detailed(issue_query_id_col1,issue_query_id_col2,[options])}}</pre>\n\n" +
         "+Parameters+\n" +
         "* _issue_query_id_col1_ : id of the issue query to get the list of issues to column 1 \n" +
         "* _issue_query_id_col2_ : id of the issue query to get the list of issues to column 2 \n\n" +
         "+Options:+\n" +
         "* -d : Displays the description of issues in both columns.\n" +
         "* -d1 : Displays the description of issues in column 1.\n" +
         "* -d2 : Displays the description of issues in column 2.\n" +
         "* -i : Displays the ID of issues in both columns.\n" +
         "* -i1 : Displays the ID of issues in column 1.\n" +
         "* -i2 : Displays the ID of issues in column 2.\n" +
         "* -s : Displays the status of issues in both columns.\n" +
         "* -s1 : Displays the status of issues in column 1.\n" +
         "* -s2 : Displays the status of issues in column 2.\n\n" +
         "+Examples:+\n" +
         "<pre>{{traceability_matrix_detailed(1,2)}} ->  Show the matrix using issue queries with id 1 and 2\n" +
         "{{traceability_matrix_detailed(20,144,-d)}} Show the matrix, with description of issues\n</pre>\n"

    desc error_message_m2

    macro :traceability_matrix_detailed do |obj, args|
    
      ## Gestion des arguments ##      
      if args.empty?
        return textilizable(error_message_m2)
      else
        if Query.find_by_id(args[0].strip) == nil
          return 'Error : Unknown query id for column 1'
        else
          query_col1_id = Query.find(args[0].strip)     
        end
        if Query.find_by_id(args[1].strip) == nil
          return 'Error : Unknown query id for column 2'
        else
          query_col2_id = Query.find(args[1].strip) 
        end
      end
      
      option_display_description_col1 = false
      option_display_description_col2 = false
      option_display_status_col1 = false
      option_display_status_col2 = false
      option_display_id_col1 = false
      option_display_id_col2 = false
      project = nil
            
      args[2..-1].each do |arg|
        case arg
        when /-d1/
          # display description of issues
          option_display_description_col1 = true
          option_display_description_col2 = false
        when /-d2/
          # display description of issues
          option_display_description_col1 = false
          option_display_description_col2 = true
        when /-d/
          # display description of issues
          option_display_description_col1 = true
          option_display_description_col2 = true
        when /-s1/
          # display status of issues
          option_display_status_col1 = true
          option_display_status_col2 = false
        when /-s2/
          # display status of issues
          option_display_status_col1 = false
          option_display_status_col2 = true
        when /-s/
          # display status of issues
          option_display_status_col1 = true
          option_display_status_col2 = true
        when /-i1/
          # display status of issues
          option_display_id_col1 = true
          option_display_id_col2 = false
        when /-i2/
          # display status of issues
          option_display_id_col1 = false
          option_display_id_col2 = true
        when /-i/
          # display status of issues
          option_display_id_col1 = true
          option_display_id_col2 = true
        when /^-p/
          project = Project.find(arg[3..arg.length-1])
        else
          puts "sinon" + arg
        end
      end

      ## Execution du controlleur ##
      mt_ctrl = MtController.new  
      
      mt_ctrl.init_macro_context(project)
      mt_ctrl.get_trackers(query_col1_id, query_col2_id)  
      mt_ctrl.build_list_of_issues
      
      disp = String.new
      disp << render(:partial => 'mt/mt_details', :locals => {:issue_cols => mt_ctrl.issue_cols, :query_cols => mt_ctrl.query_cols,
                     :issue_rows => mt_ctrl.issue_rows, :query_rows => mt_ctrl.query_rows, :issue_pairs => mt_ctrl.issue_pairs,
                     :not_seen_issue_cols => mt_ctrl.not_seen_issue_cols,
                     :option_display_id_col1 => option_display_id_col1,
                     :option_display_id_col2 => option_display_id_col2,
                     :option_display_status_col1 => option_display_status_col1,
                     :option_display_status_col2 => option_display_status_col2,
                     :option_display_description_col1 => option_display_description_col1,
                     :option_display_description_col2 => option_display_description_col2})
      return disp.html_safe

    end # Fin macro
        
  end

end

################################################################################
