require 'redmine'
require 'application_helper'

module TraceabilityMatrixHelper


  def self.get_level(issue)
    if issue.leaf?
      0
    else
      ancestors = []
      ancestors << issue
      while (ancestors.any? && !issue.is_descendant_of?(ancestors.last))
        ancestors.pop
      end
      ancestors.size
    end

  end


  def self.issue_list(issues, &block)
    ancestors = []
    issues.each do |issue|
      while (ancestors.any? && !issue.is_descendant_of?(ancestors.last))
        ancestors.pop
      end
      yield issue, ancestors.size
      ancestors << issue unless issue.leaf?
    end
  end

  # Renvoie la profondeur de l'arbre hierarchique de la table de issues
  def self.get_depth(issues)
    depth = 0
    issue_list(issues) do |issue, level|
      depth = [depth, level].max
    end
    depth + 1
  end # def
  
  # Renvoie les noeuds feuilles, faisant partie de la table issues
  # Les noeuds feuille hors de la table issues, ne sont pas prises en comptes
  # Pour avoir tous les noeuds feuille, utiliser issue.leaves.count
  def self.get_leaves(issue=nil, issues)
    if (issue == nil)
      leaves = []
      issues.each do |i|
        if !i.descendants.any?
          # l'issue n'a pas de descendant du tout, c'est donc forcement une leaf
          leaves << i
        else
          if i.descendants.select{|d| issues.include?d}.count == 0
            # l'issue n'a pas de descendant present dans la table des issues,
            # c'est donc forcement une leaf dans la portee de cette table
            leaves << i
          end
        end
      end
      leaves
    else
      (issue.leaves & issues).count
    end   
  end


end