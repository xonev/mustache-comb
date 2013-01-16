{MustacheTransformer} = require '../lib/mustache_transformer.coffee'

describe 'MustacheTransformer', ->
  transformer = null
  data = ''

  beforeEach ->
    data = ''
    transformer = new MustacheTransformer
    transformer.on 'data', (newData) ->
      data = "#{data}#{newData}"

  it 'removes entire mustache tags', ->
    transformer.write('test {{tag}} here')
    transformer.end()
    expect(data).toEqual 'test  here'

  it 'only removes until the first ending curly braces', ->
    transformer.write('test {{tag}} here}}')
    transformer.end()
    expect(data).toEqual 'test  here}}'

  it 'removes multiple mustache tags', ->
    transformer.write('test {{tag}} and other {{tag}}')
    transformer.end()
    expect(data).toEqual 'test  and other '

  it 'removes on multiple calls', ->
    transformer.write('test {{tag}} here')
    transformer.write('and {{test}} tag {{here}}')
    transformer.end()
    expect(data).toEqual 'test  hereand  tag '

  it 'removes 3/4 tags on a chunk boundary', ->
    transformer.write('test {{that}')
    transformer.write('} this tag is {{removed}')
    transformer.write('}')
    transformer.end()
    expect(data).toEqual 'test  this tag is '

  it 'does not get hung up if there is nothing further to remove', ->
    transformer.write('test {{that}')
    transformer.write('this tag is removed')
    transformer.end()
    expect(data).toEqual 'test {{that}this tag is removed'

  it 'removes 1/2 tags on a chunk boundary', ->
    transformer.write('test {{that')
    transformer.write('}} this tag is removed')
    transformer.end()
    expect(data).toEqual 'test  this tag is removed'

  it 'does not get hung up if there is nothing further to remove with a 1/2 tag', ->
    transformer.write('test {{that')
    transformer.write('does not get hung up')
    transformer.write(' at all')
    transformer.end()
    expect(data).toEqual 'test {{thatdoes not get hung up at all'

  it 'removes 1/4 tags on a chunk boundary', ->
    transformer.write('test {')
    transformer.write('{that this}} tag is removed')
    transformer.end()
    expect(data).toEqual('test  tag is removed')

  it 'doesn\'t remove a non-mustache 3/4 tag', ->
    transformer.write('this tag {{here} should not be removed')
    transformer.end()
    expect(data).toEqual('this tag {{here} should not be removed')

  it 'doesn\'t remove a non-mustache 1/2 tag', ->
    transformer.write('this tag {{here shouldn\'t be removed either')
    transformer.end()
    expect(data).toEqual('this tag {{here shouldn\'t be removed either')

  it 'doesn\'t remove a non-mustache 1/4 tag', ->
    transformer.write('none of {these things are tags')
    transformer.end()
    expect(data).toEqual('none of {these things are tags')

  xit 'removes entire sections', ->
    transformer.write('the following {{#section}}with a {{nested}}{{/section}} should be removed')
    transformer.end()
    expect(data).toEqual('the following  should be removed')

  xit 'doesn\'t remove an almost complete section', ->
    transformer.write('the following {{#section}}with a {{nested}}{{/section}')
    transformer.end()
    expect(data).toEqual('the following {{#section}}with a {{nested}}{{/section}')

  xit 'works on real html', ->
    html = """
      <div class="social_modal_container">
        <div class="dollar_off_promotion_brief_on_receipt">
          <div class="top">
            <img src="/images/icons/x_small.png" id="close_button" class="cross">
          </div>

          <div class="title">
            {{#translate}} mustache.groupon.social.promotions.{{promotion_type}}.title {{/translate}}
          </div>

          <div class="horizontal_line"></div>

          <div class="content">
            <div class="description">
              {{#translate}} mustache.groupon.social.promotions.{{promotion_type}}.description, {"line_break": "<br>"} {{/translate}}
            </div>

            <div class="sub_title">
              {{#translate}} mustache.groupon.social.promotions.{{promotion_type}}.subtitle {{/translate}}
            </div>
          </div>

        <div class="actions">
          <button id="dollar_off_button" class="button_facebook_style">
            <span class="icon">
              <img src="/images/buttons/FB_icon.png">
            </span>
            <span class="button_text">
              {{#translate}} mustache.groupon.social.promotions.{{promotion_type}}.button_text {{/translate}}
            </span>
          </button>
          <div class="link_container">
            <a id="close_dollar_off_modal_link" class="link_text" href="#">
              {{#translate}} mustache.groupon.social.promotions.{{promotion_type}}.link_text {{/translate}}
            </a>
          </div>
        </div>
        <div class="clear"></div>
      </div>
    """
    expected_html = """
        <div class="social_modal_container">
          <div class="dollar_off_promotion_brief_on_receipt">
            <div class="top">
              <img src="/images/icons/x_small.png" id="close_button" class="cross">
            </div>

            <div class="title">
            </div>

            <div class="horizontal_line"></div>

            <div class="content">
              <div class="description">
              </div>

              <div class="sub_title">
              </div>
            </div>

          <div class="actions">
            <button id="dollar_off_button" class="button_facebook_style">
              <span class="icon">
                <img src="/images/buttons/FB_icon.png">
              </span>
              <span class="button_text">
              </span>
            </button>
            <div class="link_container">
              <a id="close_dollar_off_modal_link" class="link_text" href="#">
              </a>
            </div>
          </div>
          <div class="clear"></div>
        </div>
    """
    transformer.write(html)
    transformer.end()
    expect(data).toEqual(expected_html)

