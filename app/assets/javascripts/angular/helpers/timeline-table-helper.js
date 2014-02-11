angular.module('openproject.timelines.helpers')

.factory('TimelineTableHelper', [function() {
  var NodeFilter = function(options) {
    this.options = options;
  };

  NodeFilter.prototype.memberOfHiddenOtherGroup = function(node) {
    return this.options && this.options.hide_other_group === 'yes' && node.level === 1 && node.payload.objectType === 'Project' && node.payload.getFirstLevelGrouping() === 0;
  };

  NodeFilter.prototype.hiddenOrFilteredOut = function(node) {
    var nodeObject = node.payload;

    return nodeObject.hide() || nodeObject.filteredOut();
  };

  NodeFilter.prototype.nodeExcluded = function(node) {
    return this.hiddenOrFilteredOut(node) || this.memberOfHiddenOtherGroup(node);
  };

  TimelineTableHelper = {
    convertTreeToRows: function(currentRoot, parentRow, filterCallback, processNodeCallback){
      var row, rows = [];

      if (parentRow !== null && filterCallback(currentRoot)) return rows;

      row = processNodeCallback(currentRoot, parentRow);
      rows.push(row);

      angular.forEach(currentRoot.childNodes, function(node){
        // add subtree to rows
        rows = rows.concat(TimelineTableHelper.convertTreeToRows(node, row, filterCallback, processNodeCallback));

      });

      return rows;
    },

    getRowFromNode: function(node, parentRow) {
      // ancestors

      var ancestors = [];

      if (parentRow) {
        ancestors = [parentRow];
        if(parentRow.ancestors) ancestors = parentRow.ancestors.concat(ancestors);

      }

      // compose row

      var row = {
        text: node.text,
        url: node.url,
        object: node.payload,
        ancestors: ancestors,
        level: ancestors.length,
        parent: parentRow,
        hasChildren: !!node.childNodes && node.childNodes.length > 0,
        expanded: node.expanded,

        treeNode: node // tree node has to be remembered as it is used to look up the table element for vertical offset calculation
      };

      // grouping

      isNested = row.level >= 2;
      if (row.object.objectType === 'Project' && !isNested) {
        row.firstLevelGroup        = row.object.getFirstLevelGrouping();
        row.firstLevelGroupingName = row.object.getFirstLevelGroupingName();
      } else {
        // inherit group from parent row
        row.firstLevelGroup = parentRow.firstLevelGroup;
        row.firstLevelGroupingName = parentRow.firstLevelGroupingName;
      }

      return row;
    },

    getTableRowsFromTimelineTree: function(tree, options) {
      nodeFilter = new NodeFilter(options);

      rows = TimelineTableHelper.convertTreeToRows(tree, null, function(node) { return nodeFilter.nodeExcluded(node); }, TimelineTableHelper.getRowFromNode);

      return rows;
    }
  };

  return TimelineTableHelper;
}]);
