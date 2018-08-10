<?php


use Illuminate\Database\Capsule\Manager as Capsule;

class Authorization
{

    // TODO :: 缓存
    private function checkPermission($userId = 0, $resource = '')
    {
        $allow = [
            'index-*',
            'public-*',
        ];

        // get roles - 暂不支持角色继承
        $roles = Capsule::table('assigned_role')
            ->where('entity_type', 'USER')
            ->where('entity_id', $userId)
            ->get(['role_id']);
        $roleArray = [];
        foreach ($roles as $value) {
            $roleArray[] = $value->role_id;
        }
        $roleIds = implode(',', $roleArray);

        // get resources
        $sql = <<<END
SELECT
    r.resource,
    a.resource_id
FROM
    `mp_resources` r
JOIN `mp_assigned_resource` a ON
    r.id = a.resource_id
WHERE
    (
        a.entity_id IN(?) AND a.entity_type = 'ROLE'
    ) OR(
        a.entity_id = ? AND a.entity_type = 'USER'
    )
END;
        $tmpResources = Capsule::select($sql, array($roleIds, $userId));
        $resources = [];
        foreach ($tmpResources as $value) {
            $resources[] = $value->resource;
        }
        $resources = array_merge($resources, $allow);

        // check
        foreach ($resources as $key) {
            $search = ['/', '-', '*'];
            $replace = ['\-', '\-', '[a-z0-9-_]+'];
            $pattern = '/' . str_replace($search, $replace, $key) . '/i';
            if (preg_match($pattern, $resource)) {
                return true;
            }
        }

        return false;
    }

}
