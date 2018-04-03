<?php

namespace Drupal\rhd_assemblies\Plugin\AssemblyBuild;

use Drupal\Core\Entity\Display\EntityViewDisplayInterface;
use Drupal\Core\Entity\EntityInterface;
use Drupal\assembly\Plugin\AssemblyBuildBase;
use Drupal\assembly\Plugin\AssemblyBuildInterface;
use Drupal\node\Entity\Node;

/**
 * Displays a list of recent content from Wordpress and Drupal with Disqus comments and related topics
 *  @AssemblyBuild(
 *   id = "dynamic_content_list",
 *   types = { "dynamic_content_list" },
 *   label = @Translation("Dynamic Content List")
 * )
 */
class DynamicContentListBuild extends DynamicContentFeedBuild {

  public function build(array &$build, EntityInterface $entity, EntityViewDisplayInterface $display, $view_mode) {
    $count = 6;
    $this->getItems($build, $entity, $count, 'teaser');
    $build['latest_comments'] = $this->getComments();
  }

  private function getComments() {
    // $query = [
    //   'api_secret' => 'secret_key', // api key
    //   'forum' => 'red-hat-developers-blog', // shortname
    //   // 'thread' => 'disqus_identifier' // disqus identifier, maybe optional?
    //   'limit' => 4,
    // ];

    // $client = new HttpClient();
    // $url = 'https://disqus.com/api/3.0/threads/listPosts.json';
    // $request = $this->client->request('GET', $url, ['query' => $query]);
    // $response = $request->getBody()->getContents();
    // $results = json_decode($response);

    return [
      '#markup' => 'disqus comments loading...'
    ];
  }

}
