<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Capsule\Manager as Capsule;

class Roles extends Model
{

    const CREATED_AT = 'ctime';

    const UPDATED_AT = 'mtime';

    public $timestamps = false;

    public function assign($roleId, $entityId, $entityType = 'USER')
    {
        if (!$roleId && !$entityId) {
            return false;
        }
        if (!is_array($roleId)) {
            $roleId = array($roleId);
        }
        if (!is_array($entityId)) {
            $entityId = array($entityId);
        }

        foreach ($entityId as $entity) {
            $tmpPreviousItems = Capsule::table('assigned_role')
                ->where('entity_id', $entity)
                ->where('entity_type', $entityType)
                ->get(['role_id']);
            $previousItems = [];
            foreach ($tmpPreviousItems as $value) {
                $previousItems[] = $value->role_id;
            }

            $delete = array_diff($previousItems, $roleId);
            $add = array_diff($roleId, $previousItems);
            if ($delete) {
                Capsule::table('assigned_role')
                    ->where('entity_id', $entity)
                    ->where('entity_type', $entityType)
                    ->whereIn('role_id', $delete)
                    ->delete();
            }
            if ($add) {
                $data = [];
                foreach ($add as $v) {
                    $data[] = [
                        'role_id'     => $v,
                        'entity_id'   => $entity,
                        'entity_type' => $entityType,
                    ];
                }
                Capsule::table('assigned_role')->insert($data);
            }
        }

        return true;
    }

}
