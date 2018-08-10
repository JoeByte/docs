<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Capsule\Manager as Capsule;

class Resources extends Model
{

    const CREATED_AT = 'ctime';

    const UPDATED_AT = 'mtime';

    public $timestamps = false;

    public function assign($resourceId, $entityId, $entityType = 'ROLE')
    {
        if (!$resourceId && !$entityId) {
            return false;
        }
        if (!is_array($resourceId)) {
            $resourceId = array($resourceId);
        }
        if (!is_array($entityId)) {
            $entityId = array($entityId);
        }

        foreach ($entityId as $entity) {
            $tmpPreviousItems = Capsule::table('assigned_resource')
                ->where('entity_id', $entity)
                ->where('entity_type', $entityType)
                ->get(['resource_id']);
            $previousItems = [];
            foreach ($tmpPreviousItems as $value) {
                $previousItems[] = $value->resource_id;
            }

            $delete = array_diff($previousItems, $resourceId);
            $add = array_diff($resourceId, $previousItems);
            if ($delete) {
                Capsule::table('assigned_resource')
                    ->where('entity_id', $entity)
                    ->where('entity_type', $entityType)
                    ->whereIn('resource_id', $delete)
                    ->delete();
            }
            if ($add) {
                $data = [];
                foreach ($add as $v) {
                    $data[] = [
                        'resource_id' => $v,
                        'entity_id'   => $entity,
                        'entity_type' => $entityType,
                    ];
                }
                Capsule::table('assigned_resource')->insert($data);
            }
        }

        return true;
    }

}
