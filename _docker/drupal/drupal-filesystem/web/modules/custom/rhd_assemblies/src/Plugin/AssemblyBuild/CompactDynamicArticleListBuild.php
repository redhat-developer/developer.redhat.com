<?php

namespace Drupal\rhd_assemblies\Plugin\AssemblyBuild;

use Drupal\Core\Entity\Display\EntityViewDisplayInterface;
use Drupal\Core\Entity\EntityInterface;

/**
 * Displays a list of recent content from Wordpress and Drupal.
 *
 *  @AssemblyBuild(
 *   id = "compact_dynamic_article_list",
 *   types = { "compact_dynamic_article_list" },
 *   label = @Translation("Compact Dynamic Article List")
 * )
 */
class CompactDynamicArticleListBuild extends DynamicContentFeedBuild {

  /**
   * Builds the Compact Dyanmic Article List assembly.
   */
  public function build(array &$build, EntityInterface $entity, EntityViewDisplayInterface $display, $view_mode) {
    $count = 8;
    $this->getItems($build, $entity, $count, 'compact_dynamic_article_list_item');
    // @TODO RHDX-124: Currently, we are not rendering comments properly for
    // this FE component, so I will comment this out. Once we can address this
    // in RHDX-124, then we should return to this line and uncomment this line.
    //
    // $build['latest_comments'] = $this->getComments();
  }

  /**
   * Fetches comments from Disqus.
   */
  protected function getComments() {
    $config = \Drupal::config('rhd_disqus.disqussettings');
    $shortname = $config->get('rhd_disqus_shortname') ?: FALSE;
    $api_key = $config->get('rhd_disqus_api_key') ?: FALSE;

    if (!$api_key || !$shortname) {
      return FALSE;
    }

    $comments = [
      '#type' => 'container',
    ];
    $comments['disqus'] = [
      '#markup' => '<div class="comment-wrapper" data-rhd-disqus-recent-comments data-rhd-disqus-limit="4" data-rhd-disqus-truncate>Waiting for Disqus&hellip;</div>',
      'comment_template' => [
        '#theme' => 'rhd_disqus__comment__latest',
        '#thread_title' => 'Example thread title',
        '#message' => 'Comment body goes here.',
        '#date' => date('F j, Y', time()),
        '#prefix' => '<div class="hidden template--rhd-disqus--comment--latest">',
        '#suffix' => '</div>',
      ],
      '#attached' => [
        'library' => ['rhd_disqus/rhd-disqus'],
      ],
    ];

    $comments['disqus']['comment_template']['#attributes']['class'][] = 'hidden';

    $comments['disqus']['#attached']['drupalSettings']['rhdDisqus']['apiKey'] = $api_key;
    $comments['disqus']['#attached']['drupalSettings']['rhdDisqus']['shortName'] = $shortname;

    return $comments;
  }

}
