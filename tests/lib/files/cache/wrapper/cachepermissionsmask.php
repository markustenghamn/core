<?php
/**
 * Copyright (c) 2014 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\Files\Cache\Wrapper;

use Test\Files\Cache\Cache;

class CachePermissionsMask extends Cache {
	/**
	 * @var \OC\Files\Cache\Cache $sourceCache
	 */
	protected $sourceCache;

	public function setUp() {
		parent::setUp();
		$this->storage->mkdir('foo');
		$this->sourceCache = $this->cache;
		$this->cache = $this->getMaskedCached(\OCP\PERMISSION_ALL);
	}

	protected function getMaskedCached($mask) {
		return new \OC\Files\Cache\Wrapper\CachePermissionsMask($this->sourceCache, $mask);
	}

	public function maskProvider() {
		return array(
			array(\OCP\PERMISSION_ALL),
			array(\OCP\PERMISSION_ALL - \OCP\PERMISSION_SHARE),
			array(\OCP\PERMISSION_ALL - \OCP\PERMISSION_UPDATE),
			array(\OCP\PERMISSION_READ)
		);
	}

	/**
	 * @dataProvider maskProvider
	 * @param int $mask
	 */
	public function testGetMasked($mask) {
		$cache = $this->getMaskedCached($mask);
		$data = array('size' => 100, 'mtime' => 50, 'mimetype' => 'text/plain', 'permissions' => \OCP\PERMISSION_ALL);
		$this->sourceCache->put('foo', $data);
		$result = $cache->get('foo');
		$this->assertEquals($mask, $result['permissions']);

		$data = array('size' => 100, 'mtime' => 50, 'mimetype' => 'text/plain', 'permissions' => \OCP\PERMISSION_ALL - \OCP\PERMISSION_DELETE);
		$this->sourceCache->put('bar', $data);
		$result = $cache->get('bar');
		$this->assertEquals($mask & ~\OCP\PERMISSION_DELETE, $result['permissions']);
	}

	/**
	 * @dataProvider maskProvider
	 * @param int $mask
	 */
	public function testGetFolderContentMasked($mask) {
		$this->storage->mkdir('foo');
		$this->storage->file_put_contents('foo/bar', 'asd');
		$this->storage->file_put_contents('foo/asd', 'bar');
		$this->storage->getScanner()->scan('');

		$cache = $this->getMaskedCached($mask);
		$files = $cache->getFolderContents('foo');
		$this->assertCount(2, $files);

		foreach ($files as $file) {
			$this->assertEquals($mask & ~\OCP\PERMISSION_CREATE, $file['permissions']);
		}
	}

	/**
	 * @dataProvider maskProvider
	 * @param int $mask
	 */
	public function testSearchMasked($mask) {
		$this->storage->mkdir('foo');
		$this->storage->file_put_contents('foo/bar', 'asd');
		$this->storage->file_put_contents('foo/foobar', 'bar');
		$this->storage->getScanner()->scan('');

		$cache = $this->getMaskedCached($mask);
		$files = $cache->search('%bar');
		$this->assertCount(2, $files);

		foreach ($files as $file) {
			$this->assertEquals($mask & ~\OCP\PERMISSION_CREATE, $file['permissions']);
		}
	}
}
