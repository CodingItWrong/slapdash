# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create!(
  email: "example@example.com",
  password: "password",
  display_name: "example"
)

user.notes.create!(
  title: "Markdown Feature Showcase",
  body: <<~MARKDOWN
    # Markdown Feature Showcase

    ## Text Styles

    This is **bold text**, this is *italic text*, and this is ~~strikethrough~~.

    You can also combine them: ***bold and italic***, or use `inline code` for technical terms.

    ## Headings

    ### Heading Level 3

    #### Heading Level 4

    ##### Heading Level 5

    ## Lists

    ### Unordered List

    - Apples
    - Bananas
    - Cherries
      - Bing cherries
      - Rainier cherries
    - Dates

    ### Ordered List

    1. First item
    2. Second item
    3. Third item
       1. Sub-item A
       2. Sub-item B
    4. Fourth item

    ### Task List

    - [x] Buy groceries
    - [x] Write some markdown
    - [ ] Learn a new skill
    - [ ] Read a book

    ## Links

    Visit [OpenAI](https://openai.com) or [GitHub](https://github.com) for more information.

    You can also use bare URLs: https://example.com

    ## Blockquote

    > The best way to predict the future is to invent it.
    > — Alan Kay

    ## Code Block

    ```javascript
    function greet(name) {
      console.log(`Hello, ${name}!`);
    }
    ```

    ## Horizontal Rule

    ---

    That's a wrap!
  MARKDOWN
)
