<?php
/**
 * 生成测试数据脚本
 *
 * 创建GEO索引, 字段location
 * db.accounts.createIndex({location:"2dsphere"})
 */

namespace App\Bin;

//include '../vendor/autoload.php';

use MongoDB\BSON\ObjectId;
use MongoDB\Driver\Manager;
use MongoDB\Driver\BulkWrite;
use Exception;

class GenTestData
{

    const  NUM = 1000000;


    public $config = [
        'host'       => '127.0.0.1',
        'port'       => 27017,
        'database'   => 'app',
        'collection' => 'testAccounts',
    ];


    public function run()
    {
        $this->genAccountDataMongoDb('BJ');
    }


    private function genAccountDataMongoDb($area = 'BJ', $amount = 0)
    {
        // 粗略地理坐标范围
        $location = [
            'CN' => [
                'lng' => [83, 130],
                'lat' => [21, 52],
            ],
            'BJ' => [
                'lng' => [116.212247, 116.554322],
                'lat' => [39.773558, 40.029946],
            ],
        ];
        if (!isset($location[$area])) {
            throw new Exception('argv error: area');
        }
        $loc = $location[$area];
        $lngMin = $loc['lng']['0'] * self::NUM;
        $lngMax = $loc['lng']['1'] * self::NUM;
        $latMin = $loc['lat']['0'] * self::NUM;
        $latMax = $loc['lat']['1'] * self::NUM;


        // 默认数据量 CN:2.6亿, BJ:740万
        if (empty($amount)) {
            if ($area == 'CN') {
                $amount = 260000000;
            }
            else {
                $amount = 7400000;
            }
        }


        $manager = new Manager("mongodb://{$this->config['host']}:{$this->config['port']}}");
        $step = 10000; // 如果amount不是step倍数时插入粗略数量
        for ($i = 0; $i < $amount; $i += $step) {
            $bulk = new BulkWrite();
            for ($j = 0; $j < $step; $j++) {
                $lng = mt_rand($lngMin, $lngMax) / self::NUM;
                $lat = mt_rand($latMin, $latMax) / self::NUM;
                $oid = new ObjectId();
                $bulk->insert([
                    '_id'      => $oid->__toString(),
                    'account'  => $oid->__toString(),
                    'name'     => $this->genRandom(4),
                    'gender'   => mt_rand(1, 2),
                    'locale'   => $this->genRandom(2),
                    'hometown' => $this->genRandom(2),
                    'height'   => mt_rand(158, 185),
                    'weight'   => mt_rand(40, 90),
                    'birthday' => (string)mt_rand(19700101, 20101212),
                    'cTime'    => time(),
                    'purpose'  => mt_rand(1, 5),
                    'relation' => mt_rand(1, 4),
                    'location' => ['type' => 'Point', 'coordinates' => [$lng, $lat]],
                ]);
            }
            $namespace = $this->config['database'] . '.' . $this->config['collection'];
            $manager->executeBulkWrite($namespace, $bulk);
            $complete = $i + $step;
            echo "Complete Number: $complete \r\n";
        }
    }


    private function genRandom($length = 8)
    {
        $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $random = '';
        for ($i = 0; $i < $length; $i++) {
            $random .= $chars[mt_rand(0, strlen($chars) - 1)];
        }
        return $random;
    }


}


$instance = new GenTestData();
$instance->run();
