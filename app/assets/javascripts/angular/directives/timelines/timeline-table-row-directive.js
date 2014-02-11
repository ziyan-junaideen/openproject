angular.module('openproject.timelines.directives')

.directive('timelineTableRow', [function() {
  return {
    restrict: 'A',
    // TODO restrict to 'E' once https://github.com/angular/angular.js/issues/1459 is solved
    scope: true,
    link: function(scope, element, attributes) {
      var rowObject = scope.row.object;

      scope.rowObject = rowObject;
      scope.rowObjectType = rowObject.objectType;
      scope.changeDetected = rowObject.objectType === 'PlanningElement' && (rowObject.hasAlternateDates() || rowObject.isNewlyAdded() || rowObject.isDeleted());
      scope.indent = scope.hideTreeRoot ? scope.row.level-1 : scope.row.level;

      // set dom element for vertical offset calculation
      scope.row.treeNode.dom_element = element;

      scope.$watch('row.treeNode.expanded', function(expanded, formerlyExpanded) {
        if(expanded !== formerlyExpanded) scope.timeline.rebuildAll();
      });
    }
  };
}]);
