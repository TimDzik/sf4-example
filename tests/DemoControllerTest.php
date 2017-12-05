<?php

namespace App\Tests;

use App\Controller\DemoController;
use PHPUnit\Framework\TestCase;

class DemoControllerTest extends TestCase
{
    public function testControllerResponse()
    {
        $controller = new DemoController();
        $response = $controller->index();

        $this->assertEquals(200, $response->getStatusCode());
        $this->assertContains($response->getContent(), "Welcome to Symfony");
    }
}